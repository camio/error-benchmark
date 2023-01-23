#pragma feature choice

#include <result.h>
#include <system_error>


Result<int, std::error_code> conderror_cho(bool b)
{
  if(!b) {
    return .Ok(5830); // A weird number
  } else {
    return .Error(std::make_error_code(std::errc::io_error));
  }
}
