#include <iostream>
#include <string>

enum Status
{
    WAITING,
    COMPLETED
};

class Request
{
public:
    int id;
    std::string description;
    Status status;

    Request()
    {
        status = WAITING;
        id = 0;
    }

    Request(int _id, std::string _description)
    {
        status = WAITING;
        id = _id;
        description = _description;
    }

    void ChangeStatus(Status new_status)
    {
        status = new_status;
    }
};

class Node
{
public:
    Node *next;
    Request *value;

    Node(Request *request)
    {
        value = request;
        next = nullptr;
    }
};

class TreeNode
{
public:
    TreeNode *left;
    TreeNode *right;
    Request *value;

    TreeNode(Request *request)
    {
        value = request;
        left = nullptr;
        right = nullptr;
    }
};

class RequestLinkedList
{
private:
    Node *GetNode(int index)
    {
        if (index < 0 || index >= size)
        {
            return nullptr;
        }

        Node *temp = head;
        int counter = 0;

        while (counter < index && temp != nullptr)
        {
            temp = temp->next;
            counter++;
        }

        return temp;
    }

public:
    Node *head;
    Node *tail;
    int size;

    RequestLinkedList()
    {
        head = nullptr;
        tail = nullptr;
        size = 0;
    }

    ~RequestLinkedList()
    {
        Node *current = head;

        while (current != nullptr)
        {
            Node *nextNode = current->next;
            delete current->value;
            delete current;
            current = nextNode;
        }
    }

    Request *Get(int index)
    {
        Node *node = GetNode(index);

        if (node == nullptr)
        {
            return nullptr;
        }

        return node->value;
    }

    void Append(Request *request)
    {
        Node *newNode = new Node(request);

        if (size == 0)
        {
            head = newNode;
            tail = newNode;
        }
        else
        {
            tail->next = newNode;
            tail = newNode;
        }

        size++;
    }
};

class RequestQueue
{
public:
    Node *head;
    Node *tail;
    int size;

    RequestQueue()
    {
        head = nullptr;
        tail = nullptr;
        size = 0;
    }

    ~RequestQueue()
    {
        Node *current = head;

        while (current != nullptr)
        {
            Node *nextNode = current->next;
            delete current;
            current = nextNode;
        }
    }

    Request *Front()
    {
        return head->value;
    }

    void Enqueue(Request *request)
    {
        Node *newNode = new Node(request);

        if (size == 0)
        {
            head = newNode;
            tail = newNode;
        }
        else
        {
            tail->next = newNode;
            tail = newNode;
        }

        size++;
    }

    Request *Dequeue()
    {
        Node *old_head = head;
        Request *result = old_head->value;

        head = head->next;
        delete old_head;
        size--;

        if (size == 0)
        {
            tail = nullptr;
        }

        return result;
    }

    bool Empty()
    {
        return size == 0;
    }
};

class RequestStack
{
public:
    Node *top;
    int size;

    RequestStack()
    {
        top = nullptr;
        size = 0;
    }

    ~RequestStack()
    {
        Node *current = top;

        while (current != nullptr)
        {
            Node *nextNode = current->next;
            delete current;
            current = nextNode;
        }
    }

    Request *Top()
    {
        return top->value;
    }

    void Push(Request *request)
    {
        Node *newNode = new Node(request);

        newNode->next = top;
        top = newNode;

        size++;
    }

    Request *Pop()
    {
        Node *old_top = top;
        Request *result = old_top->value;

        top = top->next;
        delete old_top;
        size--;

        return result;
    }

    bool Empty()
    {
        return size == 0;
    }
};

class RequestBST
{
private:
    void Deletion(TreeNode *parent)
    {
        if (parent == nullptr)
        {
            return;
        }

        Deletion(parent->left);
        Deletion(parent->right);
        delete parent;
        size--;
    }

public:
    TreeNode *root;
    int size;

    RequestBST()
    {
        root = nullptr;
        size = 0;
    }

    ~RequestBST()
    {
        Deletion(root);
    }

    void Insert(Request *request)
    {
        if (root == nullptr)
        {
            root = new TreeNode(request);
            size++;
            return;
        }

        TreeNode *traversal = root;

        while (true)
        {
            if (request->id == traversal->value->id)
            {
                return;
            }
            else if (request->id < traversal->value->id)
            {
                if (traversal->left == nullptr)
                {
                    TreeNode *new_node = new TreeNode(request);
                    traversal->left = new_node;
                    break;
                }
                traversal = traversal->left;
            }
            else
            {
                if (traversal->right == nullptr)
                {
                    TreeNode *new_node = new TreeNode(request);
                    traversal->right = new_node;
                    break;
                }
                traversal = traversal->right;
            }
        }

        size++;
    }

    Request *Search(int id)
    {
        TreeNode *current = root;

        while (current != nullptr)
        {
            if (id == current->value->id)
            {
                return current->value;
            }
            current = (id < current->value->id) ? current->left : current->right;
        }

        return nullptr;
    }
};