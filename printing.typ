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
  implicit-parenthesis: false,
) = {
  let display(expr, bound-ranks, depth) = display-expr(expr, highlight, bound-ranks: bound-ranks, depth: depth, implicit-parenthesis: implicit-parenthesis)

  if expr.type == "value" {
    if expr.name in bound-ranks {
      highlight(expr.name, bound-ranks.at(expr.name))
    } else {
      expr.name
    }
  } else if expr.type == "application" {
    if implicit-parenthesis {
      text(fill: gray)[(] + [#display(expr.fn, bound-ranks, depth) #display(expr.param, bound-ranks, depth)] + text(fill: gray)[)]
    } else {
      let left = if expr.fn.type == "abstraction" {
        [(] + display(expr.fn, bound-ranks, depth) + [)]
      } else {
        display(expr.fn, bound-ranks, depth)
      }

      let right = if expr.param.type in ("application", "abstraction") {
        [(] + display(expr.param, bound-ranks, depth) + [)]
      } else {
        display(expr.param, bound-ranks, depth)
      }

      [#left #right]
    }
    
  } else if expr.type == "abstraction" {
    bound-ranks.insert(expr.param, depth)
    let content = [λ] + highlight(expr.param, bound-ranks.at(expr.param)) + [.] + display(expr.body, bound-ranks, depth + 1)

    if implicit-parenthesis {
      text(fill: gray)[(] + content + text(fill: gray)[)]
    } else {
      content
    }
  }
}
