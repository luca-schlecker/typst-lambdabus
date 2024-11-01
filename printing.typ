#let expr-to-str(expr) = {
  if expr.type == "value" {
    return expr.name
  } else if expr.type == "application" {
    let left = if expr.fn.type == "abstraction" {
      "(" + expr-to-str(expr.fn) + ")"
    } else {
      expr-to-str(expr.fn)
    }
    let right = if expr.param.type in ("application", "abstraction") {
      "(" + expr-to-str(expr.param) + ")"
    } else {
      expr-to-str(expr.param)
    }
    
    return left + " " + right
  } else if expr.type == "abstraction" {
    return "λ" + expr.param + "." + expr-to-str(expr.body)
  }
}

#let display-expr(expr) = {
  if expr.type == "value" {
    expr.name
  } else if expr.type == "application" {
    let left = if expr.fn.type == "abstraction" {
      [(] + display-expr(expr.fn) + [)]
    } else {
      display-expr(expr.fn)
    }
    let right = if expr.param.type in ("application", "abstraction") {
      [(] + display-expr(expr.param) + [)]
    } else {
      display-expr(expr.param)
    }
    
    [#left #right]
  } else if expr.type == "abstraction" {
    [λ] + expr.param + [.] + display-expr(expr.body)
  }
}
