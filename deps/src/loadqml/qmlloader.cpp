#include <iostream>

extern "C"
{

extern void load_qml_app(const char* path);

}

int main(int argc, char *argv[])
{
  if(argc != 2)
  {
    std::cout << "error: " << argv[0] << " takes exactly one argument: the qml file to load" << std::endl;
  }

  load_qml_app(argv[1]);

  return 0;
}
