[
 (INT_LITERAL)
 (law_block)
 (verb_block)
 (COMMENT)
] @leaf

;; Allow blank line before
[
 (scope)
 (scope_decl)
 (struct_decl)
 (enum_decl)
 (toplevel_def)
 (COMMENT)
 (definition)
 (rounding_mode)
 (rule)
 (assertion)
 (scope_decl_item)
] @append_hardline @allow_blank_line_before

(COMMENT) @prepend_input_softline @append_hardline

(
 [ (BEGIN_CODE)
   (BEGIN_METADATA)
   (END_CODE)
 ] @append_hardline
)

[ (directive)
   (law_block)
   (code_block)
   (verb_block)
] @append_hardline @allow_blank_line_before

;; Append a space after everything
[
 ;; Generic tokens except: (COLON) (DOT) (END_CODE)
 ;;                        (BEGIN_DIRECTIVE) (LPAREN) (LAW_INCLUDE)
 (ALT)
 (AT_PAGE)
 (BEGIN_CODE)
 (BEGIN_METADATA)
 (DIRECTIVE_ARG)
 (DIV)
 (COMMA)
 (EQUAL)
 (NOT_EQUAL)
 (GREATER)
 (GREATER_EQUAL)
 (INT_LITERAL)
 (DATE_LITERAL)
 (LAW_LABEL)
 (LBRACE)
 (LESSER)
 (LESSER_EQUAL)
 (LBRACKET)
 (MINUS)
 (MULT)
 (PERCENT)
 (PLUS)
 (PLUSPLUS)
 (RBRACE)
 (RBRACKET)
 (RPAREN)
 (SEMICOLON)
 (BAR)
 (SCOPE)
 (CONSEQUENCE)
 (DATA)
 (DEPENDS)
 (DECLARATION)
 (CONTEXT)
 (DECREASING)
 (INCREASING)
 (OF)
 (LIST)
 (CONTAINS)
 (ENUM)
 (INTEGER)
 (MONEY)
 (TEXT)
 (DECIMAL)
 (DATE)
 (DURATION)
 (BOOLEAN)
 (SUM)
 (FILLED)
 (DEFINITION)
 (STATE)
 (LABEL)
 (EXCEPTION)
 (DEFINED_AS)
 (MATCH)
 (WILDCARD)
 (WITH_PATT)
 (UNDER_CONDITION)
 (IF)
 (THEN)
 (ELSE)
 (CONDITION)
 (CONTENT)
 (STRUCT)
 (ASSERTION)
 (VARIES)
 (WITH)
 (FOR)
 (ALL)
 (WE_HAVE)
 (FIXED)
 (BY)
 (RULE)
 (LET)
 (EXISTS)
 (IN)
 (AMONG)
 (SUCH)
 (THAT)
 (AND)
 (OR)
 (XOR)
 (NOT)
 (MAXIMUM)
 (MINIMUM)
 (IS)
 (EMPTY)
 (BUT_REPLACE)
 (CARDINAL)
 (YEAR)
 (MONTH)
 (DAY)
 (TRUE)
 (FALSE)
 (INPUT)
 (OUTPUT)
 (INTERNAL)
 (Round)
 (GetDay)
 (GetMonth)
 (GetYear)
 (FirstDayOfMonth)
 (LastDayOfMonth)
 (DECIMAL_LITERAL)
 (MONEY_AMOUNT)
 (MODULE_DEF)
 (MODULE_USE)
 (MODULE_ALIAS)

 ; Identifiers
 (variable)
 (label)
 (state_label)
 (module_name)
 (scope_name)
 (field_name)
 (enum_struct_name)
 (constructor_name)
 (scope_var)
] @append_space

;; Parenthesis and comma should not have any space

;; [                              ;;
;;  (LPAREN (#single_line_only!)) ;;
;; ] @append_antispace            ;;
;; [                              ;;
;;  (RPAREN (#single_line_only!)) ;;
;; ] @prepend_antispace           ;;

(COMMA) @prepend_antispace

;; No space between integer and percent for decimals declarations

(([ (DECIMAL_LITERAL) (INT_LITERAL) ] @append_antispace) . (unit_literal (PERCENT)) )

;; Scopes, structs & enums

;; scope declaration
(scope_decl
 (DECLARATION)
 (SCOPE)
 (scope_name)
 (COLON) @prepend_antispace
         @append_hardline
         @append_indent_start
 (_)
) @allow_blank_line_before @append_indent_end

;; scope definition
(scope
 (SCOPE)
 (scope_name)
 (COLON) @prepend_antispace
         @append_hardline
         @append_indent_start
 [ (rule) (definition) ]* @append_hardline
) @allow_blank_line_before @append_indent_end

(scope
 (SCOPE) @append_begin_scope
 (UNDER_CONDITION) @prepend_spaced_scoped_softline @prepend_indent_start
 condition: (expression) @append_indent_end @append_end_scope
 (#scope_id! "scope_def_cond")
)

;; struct declaration
(struct_decl
 (DECLARATION)
 (STRUCT)
 (enum_struct_name)
 (COLON) @prepend_antispace
         @append_hardline
         @append_indent_start
 (_)  @append_hardline @append_indent_end
 .
) @allow_blank_line_before

;; enum declaration
(enum_decl
 .
 (DECLARATION)
 .
 (ENUM)
 .
 (enum_struct_name)
 .
 (COLON) @prepend_antispace
         @append_hardline
         @append_indent_start
 .
 ((ALT) (enum_decl_item))* @prepend_hardline
 ) @allow_blank_line_before @append_indent_end

;; global definitions
(toplevel_def
 .
 (DECLARATION)
 (variable)
 (CONTENT)
 (typ) @append_spaced_softline
 ((DEPENDS) . (params_decl))*
) @allow_blank_line_before

(params_decl) @prepend_indent_start @append_indent_end
(params_decl
 (param_decl)
 (COMMA) @append_spaced_softline
 (param_decl)
)

;; declaration item
(scope_decl_item) @append_hardline
(scope_decl_item
 (scope_decl_item_attribute) @append_indent_start
 (CONTENT) @prepend_spaced_softline
 (STATE)? @do_nothing
 (_) @append_indent_end
 .
)

;; struct decl item
(struct_decl_item) @append_hardline
(struct_decl_item
 (DATA)
 (_) @append_indent_start @append_spaced_softline
 (CONTENT)
 (_) @append_indent_end
)

;; enum decl item
(enum_decl_item) @append_hardline
( (ALT)
  .
  (enum_decl_item
   .
   (_) @append_indent_start @append_spaced_softline
   .
   (CONTENT)
   (_) @append_indent_end
   )
)
;; state variables
(scope_decl_item
 (typ) @append_hardline
 ((STATE) @prepend_indent_start
  .
  (state_label) @append_indent_end @append_hardline
 )
)

;; state variable def
(definition
  (DEFINITION)
  (scope_var) @append_hardline
              @append_indent_start
  (STATE)
  (state_label) @append_hardline
  (_) @append_indent_end
  .
)

;; generic variable definition
((DEFINED_AS) @prepend_begin_scope
              @append_indent_start
              @append_spaced_scoped_softline
 body: (_) @append_indent_end @append_end_scope
 (#scope_id! "state_var_def")
)

;; unconditional scope def

;; n/a

;; conditional scope def
(scope
 (definition
   (DEFINITION)
   name: (scope_var) @append_indent_start @append_spaced_softline
   (UNDER_CONDITION)
   condition: (expression) @prepend_indent_start @append_indent_end @append_spaced_softline
   (CONSEQUENCE)
  ) @append_indent_end
)

;; rules
(scope
 (rule
   (RULE)
   name: (scope_var) @append_indent_start @append_spaced_softline
   (UNDER_CONDITION)
   condition: (expression) @prepend_indent_start @append_indent_end @append_spaced_softline
   (CONSEQUENCE) (NOT)? (FILLED) .
 ) @append_indent_end
)

;; labels and exceptions
(scope
 (_
  [(LABEL) (EXCEPTION)]
  .
  (label) @append_hardline
  .
  [(DEFINITION) (RULE)])
 (#multi_line_only!)
)

;; exception to implicit

(scope
 (_
  (EXCEPTION) @append_hardline .
  [(DEFINITION) (RULE)])
)

;; Lists

((LBRACKET) . (RBRACKET) @prepend_antispace)

;; list literal
(
 (LBRACKET) @append_indent_start
 .
 (collection_elements
  ((_) (SEMICOLON) @append_input_softline)*
 )
 .
 (RBRACKET) @prepend_indent_end
 (#multi_line_only!)
 .
)

;; tuples literal

(e_tuple
 .
 (LPAREN) @append_antispace
 (RPAREN) @prepend_antispace
 .
 (#single_line_only!)
)

(e_tuple
 .
 (LPAREN) @append_spaced_softline @append_indent_start
 (tuple_contents
  (COMMA)? @append_input_softline
 )
 (RPAREN) @prepend_spaced_softline @prepend_indent_end
 .
)

;; Pattern-matching

(e_match . ((WITH_PATT) @append_spaced_softline) (_))

;; Pattern-matching cases

((ALT) (match_case ((COLON) @prepend_space @append_spaced_softline @append_indent_start) (_) @append_indent_end .)) @prepend_spaced_softline

;; Let-bindings
(expression
 (e_letin
  ((LET) @prepend_begin_scope
   (IN) @append_spaced_scoped_softline
   body: (_) @append_end_scope))
 (#scope_id! "let-binding")
)

(e_letin .
 ((IN) @append_spaced_scoped_softline
  body: (_)
  )
 (#scope_id! "let-binding")
)

(e_letin .
 ((LET) . (binder)
  ((DEFINED_AS) @append_begin_scope @append_indent_start @append_spaced_scoped_softline)
  def: (_) ((IN) @prepend_indent_end @prepend_end_scope)
 )
 (#scope_id! "let-binding-def")
)

;; Pattern-tests

((e_test_match) @append_indent_start @prepend_begin_scope
 [ (AND) (OR) (XOR) ] @prepend_spaced_softline
 (_) @append_indent_end @append_end_scope
 (#scope_id! "test_match")
)
;; FIXME: probably introduce a better ast node
;; problematic case example:
;; definition x equals 3 with pattern Case1 of x
;; and x
;; >= 2 or (x < 2 and y > 2) or
;; x > 2

;; Binops

(e_binop
 [((e_test_match) @do_nothing) (_)] ;; <= weird case here, we begin scope after the lhs
 op: (_) @prepend_spaced_scoped_softline
 rhs: (_)
 (#scope_id! "binop")
) @prepend_begin_scope @append_end_scope

;; But-replace

(e_but_replace
 . (e_variable)
 . (BUT_REPLACE) @append_indent_start @append_spaced_softline
 (_)+
) @append_indent_end

;; Fields accesses

((variable) (DOT) @prepend_antispace . (variable))

(e_fieldaccess (DOT) @prepend_antispace [(qfield) (TUPLE_INDEX)])

(qenum_struct
 (DOT) @prepend_antispace)

((qenum_struct)
 (DOT) @prepend_antispace)

;; Struct expression

(
  (LBRACE) @append_spaced_softline @append_begin_scope @append_indent_start
  (struct_content_fields)
  (RBRACE) @prepend_spaced_softline @append_end_scope @prepend_indent_end
 (#scope_id! "e_struct")
)

((ALT) @prepend_spaced_scoped_softline
 .
 (struct_content_field (COLON) @prepend_antispace @append_spaced_softline @append_indent_start ) @append_indent_end
 (#scope_id! "e_struct")
)

;; If expressions

(e_ifthenelse
 (IF) @prepend_begin_scope
 cond: _ @prepend_indent_start @append_indent_end
 (THEN) @append_indent_start
        @append_spaced_scoped_softline
 then: _ @append_spaced_softline
         @append_indent_end
         @append_end_scope
 (#scope_id! "if-then")
)

((e_ifthenelse
  (ELSE) @prepend_begin_scope
         @append_spaced_scoped_softline
         @append_indent_start
  ;; do nothing on else-if
  else: [((e_ifthenelse) @do_nothing) (_) ]
  ) @append_indent_end
    @append_end_scope
 (#scope_id! "else-clause")
)

;; List-expressions

;; List existence test

(e_coll_exists
 . (EXISTS)
 . (binder)
 . (AMONG)
 . coll: (_) @append_indent_start @append_spaced_softline
 . (SUCH)
 . (THAT)
 . cond: (_) @append_indent_end
 )

;; List For-all test

(e_coll_forall
 . (FOR)
 . (ALL)
 . (binder)
 . (AMONG)
 . coll: (_) @append_indent_start @append_spaced_softline
 . (WE_HAVE)
 . cond: (_) @append_indent_end
)

;; List Mapping

(e_coll_map
 . mapf: (_) @append_indent_start @append_spaced_softline
 . (FOR)
 . (binder)
 . (AMONG)
 . coll: (_) @append_indent_end
)

;; List Filter

(e_coll_filter
 . (LIST)
 . (OF)
 . (_)
 . (AMONG)
 . coll: (_) @append_indent_start @append_spaced_softline
 . (SUCH)
 . (THAT)
 . cond: (_) @append_indent_end
)

;; List Filter + Map

(e_coll_filter_map
 . mapf: (_) @prepend_begin_scope @append_indent_start @append_spaced_scoped_softline
 . (FOR)
 . (binder)
 . (AMONG)
 . coll: (_) @append_spaced_softline @append_end_scope
 . (SUCH)
 . (THAT)
 . cond: (_) @append_indent_end
 (#scope_id! "filter_map")
 )

;; List extremum

(e_coll_extremum
 . [(MAXIMUM) (MINIMUM)]
 . (OF)
 . coll: (_) @append_indent_start @append_spaced_softline
 . (OR)
 . (IF)
 . (LIST)
 . (EMPTY)
 . (THEN)
 . dft: (_) @append_indent_end
)

;; List arg-extremum

(e_coll_arg_extremum
 . (CONTENT)
 . (OF)
 . (_)
 . (AMONG)
 . coll: (_) @append_indent_start @append_spaced_softline
 . (SUCH)
 . (THAT)
 . mapf: (_)
 . (IS)
 . [(MAXIMUM) (MINIMUM)] @append_spaced_softline
 . (OR)
 . (IF)
 . (LIST)
 . (EMPTY)
 . (THEN)
 . dft: (_) @append_indent_end
)

;; Directives

(directive                                ;;
 (BEGIN_DIRECTIVE)                        ;;
 (LAW_INCLUDE)                            ;;
 (COLON) @prepend_antispace @append_space ;;
 (DIRECTIVE_ARG)                          ;;
)                                         ;;

;; FIXME: I don't understand why the antispace is necessary...
(directive
 (BEGIN_DIRECTIVE)
 (MODULE_USE)
 (module_name) @append_antispace
 ((MODULE_ALIAS)
  (module_name))?
)

;; Fun-calls

(e_apply
 fun: (_)
 (OF) @append_spaced_softline @append_indent_start
 args: (fun_arguments) @prepend_begin_scope @append_end_scope @append_indent_end
 (#scope_id! "fun-call")
)

(fun_arguments
 (fun_argument)
 (COMMA) @append_spaced_scoped_softline
 (#scope_id! "fun-call")
)

;; Miscellaneous

((DEFINED_AS) @append_spaced_softline (expression (e_ifthenelse)))
