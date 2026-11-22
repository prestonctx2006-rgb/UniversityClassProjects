how to compile program:
- open VS code
- open up the main.cpp file (only this one is needed to run the program, but feel free to open classes.h too)
- ignore the other junk files in this folder (if there are any)
- click the play button on the top right corner of the main.cpp code window. MAKE SURE TO RUN WITH CLANG++, NOT CLANG!
- if you want to change the k value and array: go to main() in main.cpp and change the values

explanation of additional test:
- i decided to use a 2d vector (2d array was not beign friendly to me) so that i could use any size of word array i wanted. the 2d array is each iteration as the row, and the contents of each iteration as the column. the "ks" array are the K value for each iteration. These will work on any value k values and any valid arrays since i incorporated the resizing for the hash table.
- simply using a for loop to loop through the rows of the 2d array to loop every "iteration" was the cleanest solution

time and space complexity analysis:
- creating the hash table and inserting all words: O(n) time (not amortized since resizing is also O(n). ), O(1) amortized space (O(n) if resize occurs)
- creating the heap and inserting all min(D, k) elements: O(k * log(k)) or O(D * log(D)) (depending on which was the minimum), O(1) space
- merge sort: O(k * log(k)) or O(D * log(D)) (depending on which was the minimum), O(D) or O(k) space depending on which was the minimum
- tight bound full time and space per iteration: Theta(n + 2klog(k)) or Theta(n + 2Dlog(D)) (depending on minimum), O(D) or O(k) space depending on which was the minimum and amortized since a O(n) resize could occur depending on the iteration size