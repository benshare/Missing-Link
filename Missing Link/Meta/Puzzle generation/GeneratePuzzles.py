# Copyright Benjamin Share, 07/2020

import sys, os, stat
from datetime import datetime, date, timedelta
from enum import Enum
import random
from hashlib import md5

# MARK: Command Line Parsing

FLAGS = ['--daily', '--play', '--mode']

class Mode(Enum):
	RANDOM = 1
	SAME_FIRSTS = 2
	SAME_LASTS = 3
	CHAIN = 4
	FRONT_PAIR = 5
	BACK_PAIR = 6

def isValidFlag(arg):
	return arg in FLAGS
	
def getCommandLineParams():
	function_params = {fn[2:]: [] for fn in FLAGS}
	
	cur_function = None
	for i in xrange(1, len(sys.argv)):
		arg = sys.argv[i]
		if isValidFlag(arg):
			cur_function = arg[2:]
		else:
			if not cur_function:
				continue
			function_params[cur_function].append(arg)
	return function_params

class Puzzle():
	def __init__(self, first, link, last):
		self.first = first
		self.link = link
		self.last = last

	def __str__(self):
		return self.first + " - " + self.link + " - " + self.last

	def __eq__(self, other):
		return self.first == other.first and self.link == other.link and self.last == other.last

	def __hash__(self):
		return int(md5(self.first + " - " + self.link + " - " + self.last).hexdigest(), 16)

# Mark: File reading

def loadKeywordsFromFile(fn):
	keywords = []
	with open("Pack keywords/" + fn) as f:
		for line in f.readlines():
			keywords.append(line[:-1])
	return keywords

def loadPairMapsFromFile(fn):
	pair_map = {}
	reverse_pair_map = {}
	with open(fn) as f:
		for line in f.readlines():
			if line:
				asList = line.split(" ")
				if len(asList) != 2:
					continue
				first = asList[0].lower()
				second = asList[1][:-1].lower()
				if first not in pair_map:
					pair_map[first] = set()
				pair_map[first].add(second)

				if second not in reverse_pair_map:
					reverse_pair_map[second] = set()
				reverse_pair_map[second].add(first)

	return pair_map, reverse_pair_map

def loadUsedPuzzles(path):
	puzzles = []
	with open(path) as f:
		for line in f.readlines():
			as_list = line.split(" - ")
			if len(as_list) != 3:
				continue
			first = as_list[0]
			link = as_list[1]
			last = as_list[2][:-1]

			puzzles.append(Puzzle(first, link, last))
	return puzzles

def getNextPackId():
	with open(PLAY_PUZZLES_DATA_PATH + NEXT_PACK_ID_FN) as f:
		line = f.readline()
		return int(line)

def writeNextPackId(id):
	with open(PLAY_PUZZLES_DATA_PATH + NEXT_PACK_ID_FN, 'w+') as f:
		f.truncate(0)
		f.write(str(id))

# Mark: Puzzle generation

def generateAllPuzzles(pair_map, reverse_pair_map):
	puzzles = []
	puzzles_by_first = {}
	puzzles_by_link = {}
	puzzles_by_last = {}

	for link_word in pair_map:
		if link_word not in reverse_pair_map:
			continue
		for last_word in pair_map[link_word]:
			for first_word in reverse_pair_map[link_word]:
				puzzle = Puzzle(first_word, link_word, last_word)

				puzzles.append(puzzle)

				if first_word not in puzzles_by_first:
					puzzles_by_first[first_word] = []
				puzzles_by_first[first_word].append(puzzle)

				if link_word not in puzzles_by_link:
					puzzles_by_link[link_word] = []
				puzzles_by_link[link_word].append(puzzle)

				if last_word not in puzzles_by_last:
					puzzles_by_last[last_word] = []
				puzzles_by_last[last_word].append(puzzle)
				
	return puzzles, puzzles_by_first, puzzles_by_link, puzzles_by_last

def calculatePuzzleCounts(puzzles_by_first, puzzles_by_link, puzzles_by_last):
	first_puzzle_counts = {first: len(puzzles_by_first[first]) for first in puzzles_by_first}
	link_puzzle_counts = {link: len(puzzles_by_link[link]) for link in puzzles_by_link}
	last_puzzle_counts = {last: len(puzzles_by_last[last]) for last in puzzles_by_last}

	return first_puzzle_counts, link_puzzle_counts, last_puzzle_counts

def generateRandomPuzzles(puzzles, num_to_generate, used_puzzles):
	result = []
	while len(result) < num_to_generate:
		new_puzzle = random.choice(puzzles)
		if new_puzzle in used_puzzles:
			continue
		result.append(new_puzzle)
	return result

def generatePuzzlesByFirstOrLast(pair_map, puzzles_by, puzzle_counts, num_to_generate, used_puzzles=[]):
	for same_word in puzzles_by:
		# This check is technically redundant, but will terminate early and saves time.
		if len(pair_map[same_word]) < num_to_generate or puzzle_counts[same_word] < num_to_generate:
			continue

		usable_puzzles = []
		used_links = set()
		for puzzle in puzzles_by[same_word]:
			if puzzle in used_puzzles:
				continue
			if puzzle.link in used_links:
				continue
			usable_puzzles.append(puzzle)
			if len(usable_puzzles) == num_to_generate:
				break
			used_links.add(puzzle.link)
		if len(usable_puzzles) == num_to_generate:
			print("Found puzzle set using repeated word %s\n" %same_word)
			return usable_puzzles
	print("Couldn't generate usable sets of %i puzzles\n" %num_to_generate)

# MARK: Play Mode
PLAY_PUZZLES_DATA_PATH = "../../Maintenance/Data/PlayPuzzles/"
GENERATION_DATE_FN = "generationDate"
NEXT_PACK_ID_FN = "nextPackId"

def writePacks(packs, pack_name):
	print("Writing packs:", pack_name, ", ", len(packs))
	nextPackId = getNextPackId()
	for pack_num in range(len(packs)):
		pack = packs[pack_num]
		dir_path = PLAY_PUZZLES_DATA_PATH + pack_name + " %d" %(pack_num + 1)
		if not os.path.isdir(dir_path):
			os.mkdir(dir_path)
		for level_i in range(len(pack)):
			level = pack[level_i]
			fn = dir_path + "/" + str(level_i + 1)
			with open(fn, 'w+') as f:
				for puzzle in level:
					f.write(str(puzzle) + '\n')
		with open(dir_path + "/generationDate", 'w+') as f:
			f.write(str(date.today()))
		with open(dir_path + "/packId", 'w+') as f:
			f.write(str(nextPackId))
		nextPackId += 1
	writeNextPackId(nextPackId)

def writePacksDeprecated(puzzles, puzzles_per_level, levels_per_pack, pack_name):
	puzzles_per_pack = puzzles_per_level * levels_per_pack
	total_packs = len(puzzles) / puzzles_per_pack
	print("Writing %d packs" %total_packs)
	random.shuffle(puzzles)

	for pack_num in range(total_packs):
		print("Pack %d" %pack_num)
		pack_path = PLAY_PUZZLES_DATA_PATH + pack_name
		dir_path = pack_path + " %d" %(pack_num + 1) if total_packs > 1 else ""
		if not os.path.isdir(dir_path):
			mkdir(dir_path)
		for level_num in range(levels_per_pack):
			print("\tLevel %d" %level_num)
			fn = dir_path + "/" + str(level_num + 1)
			with open(fn, 'w+') as f:
				for puzzle_num in range(puzzles_per_level):
					puzzle_index = puzzles_per_pack * pack_num + puzzles_per_level * level_num + puzzle_num
					print("\t\tPuzzle %d, index: %d" %(puzzle_num, puzzle_index))
					f.write(str(puzzles[puzzle_index]) + '\n')
		with open(dir_path + "/generationDate", 'w+') as f:
			f.write(str(date.today()))

	print("%d unused puzzles:" %(len(puzzles) - puzzles_per_pack * total_packs))
	for puzzle in puzzles[puzzles_per_pack * total_packs:]:
		print(str(puzzle))

def isValidPuzzleForLevel(puzzle, level, no_repeat_answer_or_clues=True, no_repeat_bigrams=True):
	for puzzle_in_level in level:
		if no_repeat_answer_or_clues:
			if puzzle.first == puzzle_in_level.first or puzzle.link == puzzle_in_level.link or puzzle.last == puzzle_in_level.last:
				return False
		if no_repeat_bigrams:
			if puzzle.link == puzzle_in_level.first and puzzle.last == puzzle_in_level.link:
				return False
			if puzzle.link == puzzle_in_level.last and puzzle.first == puzzle_in_level.link:
				return False
	return True

def allocateLevelsToPacks(levels, ideal_pack_size=8):
	packs = []
	num_levels = len(levels)
	multiples = num_levels / ideal_pack_size
	remaining = num_levels % ideal_pack_size
	print("Allocating %d levels" %num_levels)
	print("m: %d, r: %d" %(multiples,remaining))
	# Break into two cases:
	# 1) We can remove at most 1 from the "ideal" packs to build the remaining pack up to 1 less than ideal. In this case,
	# we go with this schema (removing from the back first)
	if multiples + remaining >= ideal_pack_size - 1:
		print("In first case")
		num_packs_at_ideal = num_levels % (ideal_pack_size - 1)
		num_packs_one_below = (num_levels - num_packs_at_ideal * ideal_pack_size) / (ideal_pack_size - 1)
		print("ideal: %d, one below: %d" %(num_packs_at_ideal, num_packs_one_below))
		ind = 0
		for i in range(num_packs_at_ideal):
			packs.append(levels[ind: ind + ideal_pack_size])
			ind += num_packs_at_ideal
		for i in range(num_packs_one_below):
			packs.append(levels[ind: ind + ideal_pack_size - 1])
			ind += num_packs_at_ideal - 1

	# 2) Otherwise, we just add the excess to the existing packs, starting at the front
	else:
		print("In second case")
		new_pack_height = num_levels / multiples
		num_packs_one_higher = num_levels % multiples
		num_packs_at_height = multiples - num_packs_one_higher
		print("one higher: %d, at height: %d" %(num_packs_one_higher, num_packs_at_height))
		ind = 0
		for i in range(num_packs_one_higher):
			packs.append(levels[ind: ind + new_pack_height + 1])
			ind += new_pack_height + 1
		for i in range(num_packs_at_height):
			packs.append(levels[ind: ind + new_pack_height])
			ind += new_pack_height

	print("Allocated into packs of sizes:")
	for pack in packs:
		print(len(pack))

	return packs

# Uses greedy fitting. TODO: Make a better algorithm?
# TODO: use queues instead
def makePacksWithConstraints(puzzles, min_level_size=8, max_level_size=10, min_pack_size=4):
	print("Got %d puzzles" %len(puzzles))
	result_is_good = False
	while not result_is_good:
		random.shuffle(puzzles)
		below_min_levels = []
		at_min_levels = []
		full_levels = []
		for i_puzzle in range(len(puzzles)):
			puzzle = puzzles[i_puzzle]
			found = False
			for i_level in range(len(below_min_levels)):
				level = below_min_levels[i_level]
				if isValidPuzzleForLevel(puzzle, level):
					level.append(puzzle)
					if len(level) == min_level_size:
						at_min_levels.append(level)
						del below_min_levels[i_level]
					found = True
					break
			if found:
				continue
			for i_level in range(len(at_min_levels)):
				level = at_min_levels[i_level]
				if isValidPuzzleForLevel(puzzle, level):
					level.append(puzzle)
					if len(level) == max_level_size:
						full_levels.append(level)
						del at_min_levels[i_level]
					found = True
					break
			if found:
				continue
			# Couldn't fit it in, so make a new puzzle with it
			below_min_levels.append([puzzle])

		good_levels = []
		for level in at_min_levels + full_levels:
			good_levels.append(level)

		unmatched_puzzles = []
		for level in below_min_levels:
			unmatched_puzzles += level

		print("Created %d finished levels" %len(good_levels))
		print("Couldn't match %d puzzles" %len(unmatched_puzzles))

		yes_list = ['y', 'Y', 'yes']
		no_list = ['n', 'N', 'no']
		while True:
			yn = raw_input("Is this a good result? Y to continue, N to retry\n")
			if yn in yes_list:
				result_is_good = True
				break
			elif yn in no_list:
				break
		if result_is_good:
			packs = allocateLevelsToPacks(good_levels)
			break

	return packs

def writePacksWithKeywords(puzzles_by_first, puzzles_by_link, puzzles_by_last, keywords, pack_name):
	puzzle_set = set()
	for word in keywords:
		if word in puzzles_by_first:
			for puzzle in puzzles_by_first[word]:
				puzzle_set.add(puzzle)

		if word in puzzles_by_link:
			for puzzle in puzzles_by_link[word]:
				puzzle_set.add(puzzle)

		if word in puzzles_by_last:
			for puzzle in puzzles_by_last[word]:
				puzzle_set.add(puzzle)

	print("Found %d puzzles for pack %s" %(len(puzzle_set), pack_name))
	packs = makePacksWithConstraints(list(puzzle_set))
	# for pack in packs:
	# 	print("\n")
	# 	for puzzle in pack:
	# 		print("\n")
	# 		for p in puzzle:
	# 			print(p)
			# print(str(puzzle))
			# print(puzzle.first + " - " + puzzle.link + " - " + puzzle.last)
	writePacks(packs, pack_name)


# MARK: Daily Puzzle

# Constants
DAILY_PUZZLE_DATA_PATH = "../../Maintenance/Data/DailyPuzzles/"
USED_DAILY_PUZZLES_PATH = DAILY_PUZZLE_DATA_PATH + "usedPuzzles"
DAILY_PUZZLES_GENERATION_DATE_PATH = DAILY_PUZZLE_DATA_PATH + "mostRecentGenerationDate"

def writePuzzlesUpToDate(end_date, params, mode=Mode.RANDOM):
	days = []
	start = date.today()
	with open(DAILY_PUZZLES_GENERATION_DATE_PATH, 'r') as f:
		s = f.readline()[2:]
		print("Found date " + s)
		try:
			mostRecentGenerationDate = datetime.strptime(s, "%y-%m-%d").date()
			print(mostRecentGenerationDate)
			if mostRecentGenerationDate > start:
				start = mostRecentGenerationDate
		except:
			pass
			
	puzzles_to_generate = (end_date - start).days + 1

	if mode == Mode.RANDOM:
		puzzle_set = generateRandomPuzzles(params[0], puzzles_to_generate, params[1])
	elif mode == Mode.SAME_FIRSTS:
		puzzle_set = generatePuzzlesByFirstOrLast(params[2], params[3], params[4], puzzles_to_generate, params[1])
	elif mode == Mode.SAME_LASTS:
		puzzle_set = generatePuzzlesByFirstOrLast(params[2], params[5], params[6], puzzles_to_generate, params[1])

	print("start: %s" %str(start))
	print("end: %s" %str(end_date))
	offset = 0
	cur_day = start + timedelta(offset)
	while cur_day < end_date:
		puzzle = puzzle_set[offset]
		with open(DAILY_PUZZLE_DATA_PATH + str(cur_day), 'w+') as f:
			print("Writing puzzle\t\t%s\t\tfor day %s" %(str(puzzle), str(cur_day)))
			f.write(str(puzzle))
		offset += 1
		cur_day = start + timedelta(offset)
	with open(USED_DAILY_PUZZLES_PATH, 'a') as f:
		for puzzle in puzzle_set:
			f.write(str(puzzle) + '\n')
	with open(DAILY_PUZZLES_GENERATION_DATE_PATH, 'w') as f:
		f.write(str(end_date))

# MARK: Main

def main():
	pair_map, reverse_pair_map = loadPairMapsFromFile("PairList")
	puzzles, puzzles_by_first, puzzles_by_link, puzzles_by_last = generateAllPuzzles(pair_map, reverse_pair_map)
	first_puzzle_counts, link_puzzle_counts, last_puzzle_counts = calculatePuzzleCounts(puzzles_by_first, puzzles_by_link, puzzles_by_last)
	
	function_params = getCommandLineParams()
	
	mode_params = function_params['mode']
	if len(mode_params) == 0:
		mode = Mode.RANDOM
	elif len(mode_params) == 1:
		mode = Mode[mode_params[0]]
	else:
		raise Exception("Wrong number of arguments to 'mode' command line flag")
	
	# Daily
	for param in function_params['daily']:
		# Write puzzles for all days from now to the given date (non-inclusive) that do not already have puzzles
		end_date = datetime.strptime(param, "%y-%m-%d").date() # Format is DD-MM-YY
		used_puzzles = loadUsedPuzzles(USED_DAILY_PUZZLES_PATH)
		writePuzzlesUpToDate(end_date, (puzzles, used_puzzles, pair_map, puzzles_by_first, first_puzzle_counts, puzzles_by_last, last_puzzle_counts))
	
	print("Found " + str(len(puzzles)) + " total puzzles")


	# Play
	for param in function_params['play']:
		keywords = loadKeywordsFromFile(param)
		writePacksWithKeywords(puzzles_by_first, puzzles_by_link, puzzles_by_last, keywords, param)

def write():
	start = date.today()
	with open(DAILY_PUZZLES_GENERATION_DATE_PATH, 'r') as f:
		s = f.readline()
		print(s)
		try:
			d = datetime.strptime(s[2:], "%y-%m-%d").date()
			print(d)
			mostRecentGenerationDate = date(s)
			print(mostRecentGenerationDate)
			print(start)
			print(mostRecentGenerationDate > start)
			if mostRecentGenerationDate > start:
				start = mostRecentGenerationDate
		except:
			pass


if __name__ == "__main__":
	main()
	# write()























