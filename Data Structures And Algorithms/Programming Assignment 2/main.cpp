#include <iostream>
#include <string>
#include <algorithm>
#include <vector>
#include "classes.h"

void merge(WordNode **words, int left, int middle, int right)
{
    int size1 = middle - left + 1;
    int size2 = right - middle;

    WordNode **left_array = new WordNode *[size1];
    WordNode **right_array = new WordNode *[size2];

    for (int i = 0; i < size1; i++)
    {
        left_array[i] = words[left + i];
    }
    for (int j = 0; j < size2; j++)
    {
        right_array[j] = words[middle + 1 + j];
    }

    int i = 0;
    int j = 0;
    int k = left;

    while (i < size1 && j < size2)
    {
        if (left_array[i]->frequency > right_array[j]->frequency || (left_array[i]->frequency == right_array[j]->frequency && left_array[i]->word < right_array[j]->word))
        {
            words[k] = left_array[i];
            i++;
        }
        else
        {
            words[k] = right_array[j];
            j++;
        }
        k++;
    }

    while (i < size1)
    {
        words[k] = left_array[i];
        i++;
        k++;
    }

    while (j < size2)
    {
        words[k] = right_array[j];
        j++;
        k++;
    }
}

void merge_sort(WordNode **words, int left, int right)
{
    if (left >= right)
    {
        return;
    }
    int middle = left + (right - left) / 2;
    merge_sort(words, left, middle);
    merge_sort(words, middle + 1, right);

    merge(words, left, middle, right);
}

void print(WordNode **words, int wordCount, int iteration)
{
    std::cout << "ITERATION " << iteration << ": [";

    for (int i = 0; i < wordCount; i++)
    {
        std::cout << "(";
        std::cout << words[i]->word;
        std::cout << ", ";
        std::cout << words[i]->frequency;
        std::cout << ")";
        if (i + 1 != wordCount)
        {
            std::cout << ", ";
        }
    }

    std::cout << "]" << std::endl;
}

int main()
{
    //-----CHANGE K AND WORDS ARRAY HERE! CHANGE WORD COUNT ACCORDINGLY----------
    std::vector<std::vector<std::string>> word_bank = {{"red", "blue", "red", "green", "blue", "red", "green"}, {"apple", "orange", "apple", "banana", "apple", "banana", "orange", "lime", "lemon", "avocado", "avocado"}, {"bengals", "steelers", "browns", "ravens", "bengals", "steelers", "ravens"}};
    int ks[] = {2, 4, 3};

    for (int iteration = 0; iteration < word_bank.size(); iteration++)
    {
        int k = ks[iteration];
        int wordCount = word_bank.at(iteration).size();

        WordHashTable hash_table = WordHashTable();
        for (int i = 0; i < word_bank[iteration].size(); i++)
        {
            hash_table.insert_word(word_bank[iteration][i]);
        }
        int heapCount = std::min(k, hash_table.numDistictElements);
        std::vector<WordNode *> nodes = hash_table.get_distinct_words();
        BinaryHeap heap = BinaryHeap(heapCount);
        for (int i = 0; i < nodes.size(); i++)
        {
            heap.insert_candidate(nodes.at(i));
        }
        WordNode **heapTree = heap.tree;
        merge_sort(heapTree, 0, heapCount - 1);

        print(heapTree, heapCount, iteration + 1);
    }

    return 0;
}