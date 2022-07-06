def printf(A, i):
	print('{', end = '')
	j = 0
	while j < i:
		print(A[j], end = '')
		if j != i - 1:
			print(',', end = ' ')
		j += 1
	print('}')
	
def solve(A, i):
	for j in range(i + 1):			# Iteration
		printf(A, j)
		
def solve2(A, i):
	if i > len(A):
		return
									# Recursion
	printf(A, i)
	solve2(A, i + 1)
	
if __name__ == "__main__":
	A = [1, 2, 3]
	solve(A, 3)
	solve2(A, 0)
