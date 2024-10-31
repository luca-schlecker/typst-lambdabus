#import "lambda.typ": *

#let parsed = lambda-parse-expr("λx.(y z)")

#parsed

#lambda-display-expr(parsed)