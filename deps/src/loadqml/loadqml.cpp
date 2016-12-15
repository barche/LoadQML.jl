#include <vector>

#include <QApplication>
#include <QQmlApplicationEngine>

extern "C"
{

void load_qml_app(const char* path)
{
  static int argc = 1;
  static std::vector<char*> argv_buffer;
  if(argv_buffer.empty())
  {
    argv_buffer.push_back(const_cast<char*>("julia"));
  }
  QApplication app(argc, &argv_buffer[0]);
  QQmlApplicationEngine* e = new QQmlApplicationEngine();
  e->load(path);
  app.exec();
}

} // namespace qmlwrap
