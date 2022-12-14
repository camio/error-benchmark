#include <tl/expected.hpp>

#include <system_error>

tl::expected<int, std::error_code> conderror_exp(bool b)
{
  if(!b) {
    return {42};
  } else {
    return tl::unexpected<std::error_code>{std::make_error_code(std::errc::io_error)};
  }
}
