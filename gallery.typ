#import "lib.typ": *
#set page(width: auto, height: auto, margin: .5cm)

#table(
  columns: 2,
  inset: 0.5cm,
  align: center + horizon,
  [
    ```typst
    // both '\\' and 'λ' work ↴
    #lmd.display("λy.(\\x.x) (λx.x) y")
    ```

    #display("λy.(\\x.x) (λx.x) y")
  ],
  [
    ```typst
    // strings and parsed expressions can both be
    // used with lambdabus' external interface
    #lmd.display(lmd.parse("λy.(\\x.x) (λx.x) y"))
    ```

    #display("λy.(\\x.x) (λx.x) y")
  ],
  [
    ```typst
    // Short-hand syntax
    // for multiple parameters
    #lmd.display("λx y.f")
    ```

    #display("λx y.f")
  ],
  table.cell(rowspan: 2)[
    ```typst
    // Syntax Tree of the λ-Expression
    #lmd.parse("λx.a x")
    ```
    #align(left)[
      #parse("λx.a x")
    ]
  ],
  [
    ```typst
    // Get the free/unbound variables
    // in an expression
    #lmd.free-vars("(λx.λy.f g x y) y")
    ```

    #free-vars("(λx.λy.f g x) y")
  ],
  [
    ```typst
    // Display with color coded
    // bound variables
    #lmd.display(
      "(λx.x) (λx.λy.f g x y) y",
      show-bound: true
    )
    ```

    #display(
      "(λx.x) (λx.λy.f g x y) y",
      show-bound: true
    )
  ],
  [
    ```typst
    // Automatic normalization
    // using normal-order reduction
    #let norm = lmd.normalize(
      "(λx y.x x y y) a b"
    )
    #lmd.display(norm)
    ```
    
    #display(normalize("(λx y.x x y y) a b"))
  ],
  [
    ```typst
    // α-Conversion
    #lmd.display(lmd.alpha("λx.x", "y"))
    ```

    #display(alpha("λx.x", "y"))
  ],
  [
    ```typst
    // β-Conversion
    #lmd.display(lmd.beta("(λx.x) y"))
    ```

    #display(beta("(λx.x) y"))
  ],
  [
    ```typst
    // η-Conversion
    #lmd.display(lmd.eta("λx.f x"))
    ```

    #display(eta("λx.f x"))
  ],
  [
    ```typst
    // Convert to string
    #let expr = lmd.parse("λx.x")
    #repr(lmd.to-str(expr))
    ```

    #repr(to-str(parse("λx.x")))
  ],
  table.cell(colspan: 2)[
    ```typst
    // Automatic step-by-step normalization
    // The same bound variable has the same color
    // across multiple steps.
    #lmd.normalization-steps("λx.(λa.a) (λa.a) (λa.a) (λa.a) (λa.a) (λa.a) x")
      .map(lmd.display.with(show-bound: true))
      .join([\ = ])

    ```

    #box[#align(left)[
        #normalization-steps("λx.(λa.a) (λa.a) (λa.a) (λa.a) (λa.a) (λa.a) x").map(display.with(show-bound: true)).join([\ = ])
    ]]
  ],
  table.cell(rowspan: 2)[
    ```typst
    // display(..) can be further customized:
    #lmd.display(
      // custom colors for bound variables
      colors: (red, green, blue),
      // print all implicit parenthesis
      implicit-parenthesis: false,
      // custom highlighting function. example:
      // print variable depth instead of color
      highlight-bound: (var, rank)
        => var + str(rank)
    )
    ```
  ],
  [
    ```typst
    #lmd.is-normalizable("(λx.x x) (λx.x x)")
    ```

    #is-normalizable("(λx.x x) (λx.x x)")

    ```typst
    // Will result in a panic
    #lmd.normalize("(λx.x x) (λx.x x)")
    ```
  ],
  [
    ```typst
    #lmd.is-normalform("λx.x")
    ```

    #is-normalform("λx.x")
  
    ```typst
    #lmd.is-normalform("(λx.x) y")
    ```

    #is-normalform("(λx.x) y")
  
    ```typst
    #lmd.is-normalform(
      lmd.normalize("(λx.x) y")
    )
    ```

    #is-normalform(normalize("(λx.x) y"))
  ],
)