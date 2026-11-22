#include <iostream>
#include <string>
#include <vector>
#include <functional>

std::hash<std::string> hashFunction;

class WordNode
{
public:
    WordNode *next;
    int frequency;
    std::string word;

    WordNode(std::string parameter_word)
    {
        word = parameter_word;
        next = nullptr;
        frequency = 1;
    }

    WordNode() {}
};

class WordLinkedList
{
public:
    WordNode *head;
    WordNode *tail;

    WordLinkedList()
    {
        head = nullptr;
        tail = nullptr;
    }

    ~WordLinkedList()
    {
        WordNode *current = head;

        while (current != nullptr)
        {
            WordNode *nextNode = current->next;
            delete current;
            current = nextNode;
        }
    }

    int get_frequency(std::string word)
    {
        WordNode *current = head;
        while (current != nullptr)
        {
            if (current->word == word)
            {
                return current->frequency;
            }

            current = current->next;
        }
        return -1;
    }

    void append(std::string word)
    {
        WordNode *newNode = new WordNode(word);

        if (head == nullptr)
        {
            head = newNode;
            tail = newNode;
        }
        else
        {
            tail->next = newNode;
            tail = newNode;
        }
    }
};

class WordHashTable
{
private:
    WordNode *find(std::string word)
    {
        size_t hashValue = hashFunction(word);
        int index = hashValue % capacity;

        WordNode *current = buckets[index].head;
        while (current != nullptr)
        {
            if (current->word == word)
            {
                return current;
            }

            current = current->next;
        }

        return nullptr;
    }

    void rehash(int newCapacity, WordLinkedList *newBuckets)
    {
        for (int i = 0; i < capacity; i++)
        {
            WordNode *current = buckets[i].head;
            while (current != nullptr)
            {
                int index = hashFunction(current->word) % newCapacity;
                newBuckets[index].append(current->word);

                newBuckets[index].tail->frequency = current->frequency;

                current = current->next;
            }
        }
    }

    void resize()
    {
        int newCapacity = 2 * capacity + 1;
        WordLinkedList *newBuckets = new WordLinkedList[newCapacity];
        rehash(newCapacity, newBuckets);
        delete[] buckets;
        buckets = newBuckets;
        capacity = newCapacity;
    }

public:
    WordLinkedList *buckets;
    int numElements;
    int capacity;
    int numDistictElements;

    WordHashTable()
    {
        numElements = 0;
        capacity = 8;
        numDistictElements = 0;

        buckets = new WordLinkedList[capacity];
    }

    ~WordHashTable()
    {
        delete[] buckets;
    }

    void insert_word(std::string word)
    {
        if (numDistictElements > capacity)
        {
            resize();
        }

        WordNode *existing = find(word);
        if (existing != nullptr)
        {
            existing->frequency++;
            return;
        }

        int index = hashFunction(word) % capacity;

        buckets[index].append(word);

        numElements++;
        numDistictElements++;
    }

    std::vector<WordNode *> get_distinct_words()
    {
        std::vector<WordNode *> words = std::vector<WordNode *>();
        for (int i = 0; i < capacity; i++)
        {
            WordNode *current = buckets[i].head;
            while (current != nullptr)
            {
                words.push_back(current);
                current = current->next;
            }
        }

        return words;
    }
};

class BinaryHeap
{
private:
    void percolate_up(int index, WordNode *node)
    {
        while (true)
        {
            if (index == 0)
            {
                return;
            }
            int parent = floor((index - 1) / 2);
            if (tree[parent]->frequency > node->frequency || (tree[parent]->frequency == node->frequency && tree[parent]->word < node->word))
            {
                WordNode *temp = tree[parent];
                tree[parent] = node;
                tree[index] = temp;
                index = parent;
            }
            else
            {
                return;
            }
        }
    }

    void percolate_down(int index)
    {
        while (true)
        {
            if (index * 2 + 1 >= numElements)
            {
                return;
            }
            int leftChild = index * 2 + 1;
            int rightChild = leftChild + 1;
            int worstChild = -1;
            if (rightChild >= capacity)
            {
                worstChild = leftChild;
            }
            else if (tree[leftChild]->frequency > tree[rightChild]->frequency || (tree[leftChild]->frequency == tree[rightChild]->frequency && tree[leftChild]->word < tree[rightChild]->word))
            {
                worstChild = rightChild;
            }
            else
            {
                worstChild = leftChild;
            }

            if (tree[worstChild]->frequency < tree[index]->frequency || (tree[worstChild]->frequency == tree[index]->frequency && tree[worstChild]->word > tree[index]->word))
            {
                WordNode *temp = tree[worstChild];
                tree[worstChild] = tree[index];
                tree[index] = temp;
                index = worstChild;
            }
            else
            {
                return;
            }
        }
    }

public:
    WordNode **tree;
    int numElements;
    int capacity;

    BinaryHeap(int k)
    {
        numElements = 0;
        tree = new WordNode *[k];
        capacity = k;
    }

    ~BinaryHeap()
    {
        delete[] tree;
    }

    void insert_candidate(WordNode *node)
    {
        if (capacity == 0)
            return;

        if (numElements == capacity && (tree[0]->frequency < node->frequency || (tree[0]->frequency == node->frequency && tree[0]->word > node->word)))
        {
            tree[0] = node;
            percolate_down(0);
        }
        else if (numElements != capacity)
        {
            tree[numElements] = node;
            percolate_up(numElements, node);
            numElements++;
        }
    }
};