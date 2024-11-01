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

#let display-expr(
  expr,
  highlight,
  bound-ranks: (:),
  depth: 0,
) = {
  if expr.type == "value" {
    if expr.name in bound-ranks {
      highlight(expr.name, bound-ranks.at(expr.name))
    } else {
      expr.name
    }
  } else if expr.type == "application" {
    let left = if expr.fn.type == "abstraction" {
      [(] + display-expr(expr.fn, highlight, bound-ranks: bound-ranks, depth: depth) + [)]
    } else {
      display-expr(expr.fn, highlight, bound-ranks: bound-ranks, depth: depth)
    }

    let right = if expr.param.type in ("application", "abstraction") {
      [(] + display-expr(expr.param, highlight, bound-ranks: bound-ranks, depth: depth) + [)]
    } else {
      display-expr(expr.param, highlight, bound-ranks: bound-ranks, depth: depth)
    }
    
    [#left #right]
  } else if expr.type == "abstraction" {
    bound-ranks.insert(expr.param, depth)
    [λ] + highlight(expr.param, bound-ranks.at(expr.param)) + [.] + display-expr(expr.body, highlight, bound-ranks: bound-ranks, depth: depth + 1)
  }
}
