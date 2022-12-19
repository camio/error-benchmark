#include <system_error>

int conderror_exc(bool b)
{
  if(!b) {
    return 5830; // A weird number
  } else {
    throw std::system_error( std::make_error_code(std::errc::io_error) );
  }
}
