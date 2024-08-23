#include <iostream>

int main() {
    std::cout << "@cpp@" << " v" << APP_VERSION_MAJOR << "." << APP_VERSION_MINOR << "." << APP_VERSION_PATCH << APP_VERSION_DIRTY << std::endl;

    return 0;
}