#import "parsing.typ"
#import "lambda.typ"
#import "printing.typ"

#let parse(input) = {
  if type(input) == str {
    return parsing.parse-expr(input.codepoints())
  } else {
    panic("Only a string can be parsed as a λ-Calculus expression")
  }
}

#let free-vars(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.free-vars(expr)
}

#let normalize(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.normalize(expr)
}

#let is-normalizable(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.is-normalizable(expr)
}

#let is-normalform(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.is-normalform(expr)
}

#let alpha(expr, new-var-name) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.alpha-conversion(expr, new-var-name)
}

#let beta(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.beta-reduction(expr)
}

#let eta(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.eta-reduction(expr)
}

#let to-str(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return printing.expr-to-str(expr)
}

#let display(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return printing.display-expr(expr)
}