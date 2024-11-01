
#let lambda-parse-literal(input: array) = {
  if input.first() not in ("λ", " ", ".", "\\", "(") and input.len() == 1 {
    return (type: "value", name: input.first())
  } else {
    panic("Not a valid λ-Calculus Literal: '" + input.first() + "'")
  }
}

#let lambda-parse-abstraction(input: array, parse-expr: function) = {
  let result = (
    type: "abstraction",
    param: (),
    body: (),
  )

  if input.remove(0) not in ("λ", "\\") {
    panic("Not a valid λ-Calculus Abstraction (needs to begin with λ or \\): '" + input.join() + "'")
  }

  let char = input.remove(0)
  if char not in ("λ", " ", ".", "\\") {
    result.param = char
  } else if char == "." {
    panic("Not a valid λ-Calculus Abstraction (missing parameter): '" + "λ" + char + input.join() + "'")
  } else {
    panic("Not a valid λ-Calculus Abstraction (invalid parameter '" + char + "'): '" + input.join() + "'")
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
    panic("Not a valid λ-Calculus Abstraction (invalid parameter '" + char + "'): '" + input.join() + "'")
  }

  return result
}

#let lambda-parse-parenthesis(input: array, parse-expr: function) = {
  if input.first() != "(" or input.last() != ")" {
    panic("Not a valid λ-Calculus expression (wrong parenthesis placement): '" + input.join() + "'")
  }

  return parse-expr(input.slice(1, -1))
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
    panic("Not a valid λ-Calculus application (missing space): '" + input.join() + "'")
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
      panic("Not a valid λ-Calculus expression: '" + input.join() + "'")
    }
  } else {
    panic("Only an array of strings and a string can be parsed as a λ-Calculus expression")
  }
}

#let lambda-free-vars(expr) = {
  if expr.type == "value" {
    return (expr.name,)
  } else if expr.type == "application" {
    return (lambda-free-vars(expr.fn) + lambda-free-vars(expr.param)).dedup()
  } else if expr.type == "abstraction" {
    return lambda-free-vars(expr.body).filter(it => it != expr.param)
  }
}

#let lambda-expr-to-str(expr) = {
  if expr.type == "value" {
    return expr.name
  } else if expr.type == "application" {
    let left = if expr.fn.type == "abstraction" {
      "(" + lambda-expr-to-str(expr.fn) + ")"
    } else {
      lambda-expr-to-str(expr.fn)
    }
    let right = if expr.param.type in ("application", "abstraction") {
      "(" + lambda-expr-to-str(expr.param) + ")"
    } else {
      lambda-expr-to-str(expr.param)
    }
    
    return left + " " + right
  } else if expr.type == "abstraction" {
    return "λ" + expr.param + "." + lambda-expr-to-str(expr.body)
  }
}

#let lambda-alpha-conversion-impl(expr, old-param-name, new-param-name) = {
  if expr.type == "abstraction" {
    if expr.param == old-param-name {
      return expr
    } else {
      expr.body = lambda-alpha-conversion-impl(expr.body, old-param-name, new-param-name)
      return expr
    }
  } else if expr.type == "application" {
    expr.fn = lambda-alpha-conversion-impl(expr.fn, old-param-name, new-param-name)
    expr.param = lambda-alpha-conversion-impl(expr.param, old-param-name, new-param-name)
    return expr
  } else if expr.type == "value" {
    expr.name = expr.name.replace(old-param-name, new-param-name)
    return expr
  }
}

#let lambda-alpha-conversion(expr, new-param-name) = {
  if type(new-param-name) != str {
    panic("New parameter name has to be of type str")
  }

  lambda-parse-literal(input: new-param-name.codepoints())

  if expr.type != "abstraction" {
    panic("Can only apply λ-Calculus alpha-conversion on abstraction, got: '" + expr.type + "'")
  }

  if lambda-free-vars(expr).contains(new-param-name) {
    panic("Cannot apply λ-Calculus alpha-conversion (new variable name '" + new-param-name + "' already bound): '" + lambda-expr-to-str(expr) + "'")
  }

  let old-param-name = expr.param
  expr.param = new-param-name

  return lambda-alpha-conversion-impl(expr, old-param-name, new-param-name)
}

#let lambda-beta-reduction-impl(expr, old-param-name, new-value) = {
  if expr.type == "value" {
    if expr.name == old-param-name {
      return new-value
    } else {
      return expr
    }
  } else if expr.type == "application" {
    expr.fn = lambda-beta-reduction-impl(expr.fn, old-param-name, new-value)
    expr.param = lambda-beta-reduction-impl(expr.param, old-param-name, new-value)
    return expr
  } else if expr.type == "abstraction" {
    if expr.param == old-param-name {
      return expr
    } else {
      if expr.param in lambda-free-vars(new-value) {
        panic("Cannot apply λ-Calculus beta-reduction (free variable '" + expr.param + "' would be bound): '" + lambda-expr-to-str(expr) + "'")
      } else {
        expr.body = lambda-beta-reduction-impl(expr.body, old-param-name, new-value)
        return expr
      }
    }
  }
}

#let lambda-beta-reduction(expr) = {
  if expr.type != "application" {
    panic("Can only apply λ-Calculus beta-reduction on applications, got: '" + expr.type + "'")
  }

  if expr.fn.type != "abstraction" {
    panic("Can only apply λ-Calculus beta-reduction on applications on abstractions, was: '" + expr.fn.type + "'")
  }

  return lambda-beta-reduction-impl(expr.fn.body, expr.fn.param, expr.param)
}

#let lambda-eta-reduction(expr) = {
  if expr.type != "abstraction" {
    panic("Can only apply λ-Calculus eta-reduction on abstractions, got: '" + expr.type + "'")
  }

  if expr.body.type != "application" {
    panic("Can only apply λ-Calculus eta-reduction on abstractions with an application body, got: '" + expr.body.type + "'")
  }

  if expr.body.param.type != "value" or expr.body.param.name != expr.param {
    panic("Can only apply λ-Calculus eta-reduction on abstractions with an application body with the abstraction variable on the right side, got: '" + expr.body.type + "'")
  }

  return expr.body.fn
}

#let lambda-normalize-reducable(expr) = {
  if expr.type == "value" {
    return false
  } else if expr.type == "application" {
    if expr.fn.type == "abstraction" {
      return true
    } else {
      return lambda-normalize-reducable(expr.fn) or lambda-normalize-reducable(expr.param)
    }
  } else if expr.type == "abstraction" {
    return lambda-normalize-reducable(expr.body)
  }
}

#let lambda-normalize-reduce(expr) = {
  if expr.type == "value" {
    return expr
  } else if expr.type == "application" {
    if expr.fn.type == "abstraction" {
      return lambda-beta-reduction(expr)
    } else {
      if lambda-normalize-reducable(expr.fn) {
        expr.fn = lambda-normalize-reduce(expr.fn)
        return expr
      } else {
        expr.param = lambda-normalize-reduce(expr.param)
        return expr
      }
    }
  } else if expr.type == "abstraction" {
    return lambda-normalize-reduce(expr.body)
  }
}

#let lambda-normalize(expr) = {
  let prev = (expr,)
  while lambda-normalize-reducable(expr) {
    expr = lambda-normalize-reduce(expr)
    if expr in prev {
      panic("λ-Calculus expression not normalizable")
    }
    prev.push(expr)
  }
  return expr
}

#let lambda-is-normalform(expr) = {
  lambda-normalize(expr) == expr
}

#let lambda-display-expr(expr) = {
  if expr.type == "value" {
    expr.name
  } else if expr.type == "application" {
    let left = if expr.fn.type == "abstraction" {
      [(] + lambda-display-expr(expr.fn) + [)]
    } else {
      lambda-display-expr(expr.fn)
    }
    let right = if expr.param.type in ("application", "abstraction") {
      [(] + lambda-display-expr(expr.param) + [)]
    } else {
      lambda-display-expr(expr.param)
    }
    
    [#left #right]
  } else if expr.type == "abstraction" {
    [λ] + expr.param + [.] + lambda-display-expr(expr.body)
  }
}