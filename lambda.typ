
#let lambda-parse-literal(input: array) = {
  if input.first() not in ("λ", " ", ".", "\\", "(") {
    return (type: "value", name: input.first())
  } else {
    assert(false)
  }
}

#let lambda-parse-abstraction(input: array, parse-expr: function) = {
  let result = (
    type: "abstraction",
    param: (),
    body: (),
  )

  if input.remove(0) not in ("λ", "\\") {
    assert(false)
  }

  let char = input.remove(0)
  if char not in ("λ", " ", ".", "\\") {
    result.param = char
  } else {
    assert(false)
  }

  char = input.remove(0)
  if char == "." {
    result.body = parse-expr(input)
  } else if char == " " {
    result.body = lambda-parse-abstraction(
      input: "λ".codepoints() + input,
      parse-expr: parse-expr
    )
  } else {
    assert(false)
  }

  return result
}

#let lambda-parse-parenthesis(input: array, parse-expr: function) = {
  let open-brackets = 0
  let end = none
  for (index, value) in input.enumerate() {
    if value == "(" {
      open-brackets += 1
    } else if value == ")" {
      open-brackets -= 1
    }

    if open-brackets == 0 {
      end = index
    }
  }
  
  if end == none {
    assert(false)
  } else {
    return parse-expr(input.slice(1, end))
  }
}

#let lambda-find-application-space(input: array) = {
  let last-space = none
  let in-abstr = false
  let in-par = 0
  for (index, value) in input.enumerate() {
    if value in ("λ", "\\") { in-abstr = true }
    else if value == "." { in-abstr = false }
    else if value == "(" { in-par += 1 }
    else if value == ")" { in-par -= 1 }
    
    if value == " " and in-abstr == false and in-par == 0 {
      last-space = index
    }
  }

  return last-space
}

#let lambda-parse-application(input: array, parse-expr: function) = {
  let last-space = lambda-find-application-space(input: input)
  if last-space == none {
    assert(false)
  } else {
    let fn = parse-expr(input.slice(0, last-space))
    let param = parse-expr(input.slice(last-space + 1))

    return (
      type: "application",
      fn: fn,
      param: param,
    )
  }
}

#let lambda-is-application(input: array) = {
  return lambda-find-application-space(input: input) != none
}

#let lambda-parse-expr(input) = {
  if type(input) == str {
    lambda-parse-expr(input.codepoints())
  } else if type(input) == array {
    if input.first() in ("λ", "\\") {
      return lambda-parse-abstraction(input: input, parse-expr: lambda-parse-expr)
    } else if lambda-is-application(input: input) {
      return lambda-parse-application(input: input, parse-expr: lambda-parse-expr)
    } else if input.first() == "(" {
      return lambda-parse-parenthesis(input: input, parse-expr: lambda-parse-expr)
    } else if input.first() not in ("λ", " ", ".", "\\", "(") and input.len() == 1 {
      return lambda-parse-literal(input: input)
    } else {
      assert(false)
    }
  } else {
    assert(false)
  }
}