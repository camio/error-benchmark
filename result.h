#ifndef RESULT_H_
#define RESULT_H_

#pragma feature choice

template<typename T, typename E>
choice Result {
  Ok(T),
  Error(E),
};
#endif
