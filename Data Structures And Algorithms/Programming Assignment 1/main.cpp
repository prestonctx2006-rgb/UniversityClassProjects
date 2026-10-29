#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include "classes.h"

RequestLinkedList linked_list = RequestLinkedList();
RequestQueue queue = RequestQueue();
RequestStack stack = RequestStack();
RequestBST bst = RequestBST();
std::ofstream out;

void Add(int id, std::string description)
{
    if (bst.Search(id) != nullptr)
    {
        out << "ID ALREADY EXISTS" << std::endl;
        return;
    }

    Request *new_request = new Request(id, description);
    linked_list.Append(new_request);
    queue.Enqueue(new_request);
    bst.Insert(new_request);
}

void Process()
{
    Request *next_request = queue.Dequeue();
    next_request->ChangeStatus(COMPLETED);
    stack.Push(next_request);
}

void Undo()
{
    Request *last_request = stack.Pop();
    last_request->ChangeStatus(WAITING);
    queue.Enqueue(last_request);
}

void GetStatus(int id)
{
    Request *req = bst.Search(id);
    if (req == nullptr)
    {
        out << "REQUEST NOT FOUND" << std::endl;
        return;
    }
    std::string status = req->status == 0 ? "WAITING" : "COMPLETED";
    out << id << "," << req->description << "," << status << std::endl;
}

void Print()
{
    if (linked_list.size == 0)
    {
        out << "EMPTY" << std::endl;
        return;
    }

    for (int i = 0; i < linked_list.size; i++)
    {
        Request *req = linked_list.Get(i);
        std::string status = req->status == 0 ? "WAITING" : "COMPLETED";
        out << req->id << "," << req->description << "," << status << std::endl;
    }
}

std::vector<std::string> split(std::string line)
{
    std::string temp = "";
    std::vector<std::string> result = {};
    for (char &c : line)
    {
        if (c == ',')
        {
            result.push_back(temp);
            temp = "";
        }
        else
        {
            temp += c;
        }
    }
    if (temp != "")
    {
        result.push_back(temp);
    }

    return result;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        out << "USAGE: ./main test1.txt" << std::endl;
        return 1;
    }

    std::string filename = argv[1];

    std::ifstream in(filename);
    if (!in.is_open())
    {
        out << "ERROR: COULDN'T OPEN INPUT FILE " << filename << std::endl;
        return 1;
    }

    int index_of_dot = filename.rfind('.');
    std::string raw_filename = filename.substr(0, index_of_dot);

    out.open(raw_filename + "_output.txt");
    if (!out.is_open())
    {
        out << "ERROR: COULDN'T CREATE OUTPUT FILE " << filename << std::endl;
        return 1;
    }

    // std::cout << "\nWelcome to the Help Desk Management System (HDMS). Use the \"COMMANDS\" line to receive a list of all commands." << std::endl
    //<< std::endl;

    std::string command = "";
    while (std::getline(in, command))
    {
        // std::cout << "hdms >> ";
        // std::getline(std::cin, command);
        if (!command.empty() && command.back() == '\r')
        {
            command.pop_back();
        }

        std::vector<std::string> line = split(command);

        if (!line.empty())
        {
            for (char &c : line.at(0))
            {
                c = static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
            }

            if (line.at(0) == "COMMANDS")
            {
                out << "HDMS COMMANDS:\n- ADD,id,description | Adds new request, sets status to waiting\n- PROCESS | Processes the next request in the queue\n- UNDO | Undo the most completed request\n- STATUS,id | Searches for the status of the request\n- PRINT | Prints all requests\n- QUIT | Quit the program" << std::endl;
            }
            else if (line.at(0) == "QUIT")
            {
                break;
            }
            else
            {
                if (line.at(0) == "ADD")
                {
                    Add(std::stoi(line.at(1)), line.at(2));
                }
                else if (line.at(0) == "PROCESS")
                {
                    if (!queue.Empty())
                    {
                        Process();
                    }
                    else
                    {
                        out << "NO REQUESTS WAITING" << std::endl;
                    }
                }
                else if (line.at(0) == "UNDO")
                {
                    if (!stack.Empty())
                    {
                        Undo();
                    }
                    else
                    {
                        out << "NOTHING TO UNDO" << std::endl;
                    }
                }
                else if (line.at(0) == "STATUS")
                {
                    GetStatus(std::stoi(line.at(1)));
                }
                else if (line.at(0) == "PRINT")
                {
                    Print();
                }
                else
                {
                    out << "COMMAND NOT RECOGNIZED" << std::endl;
                }
            }
        }
    }

    return 0;
}