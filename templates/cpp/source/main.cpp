#include <iostream>

int main() {
    std::cout << APP_NAME << " v" << APP_VERSION_MAJOR << "." << APP_VERSION_MINOR << "." << APP_VERSION_PATCH << APP_VERSION_DIRTY << std::endl;

    return 0;
}