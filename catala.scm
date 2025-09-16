[
 (INT_LITERAL)
 (law_block)
 (verb_block)
 (COMMENT)
 (ATTRIBUTE)
] @leaf

;; Allow blank line before
[
 (scope)
 (scope_decl)
 (struct_decl)
 (enum_decl)
 (toplevel_def)
 (COMMENT)
 (ATTRIBUTE)
 (definition)
 (rounding_mode)
 (rule)
 (assertion)
 (scope_decl_item)
] @append_hardline @allow_blank_line_before

[(COMMENT) (ATTRIBUTE)] @prepend_input_softline @append_hardline

(
 [ (BEGIN_CODE)
   (BEGIN_METADATA)
   (BEGIN_VERB_BLOCK)
   (END_CODE)
 ] @append_hardline @allow_blank_line_before
)

[ (directive)
  (law_block)
  (code_block)
  (verb_block)
] @append_hardline @prepend_hardline @allow_blank_line_before

;; Append a space after everything
[
 ;; Generic tokens except: (COLON) (DOT) (END_CODE)
 ;;                        (LPAREN) (LAW_INCLUDE)
 (ALT)
 (AT_PAGE)
 (BEGIN_CODE)
 (BEGIN_METADATA)
 (BEGIN_DIRECTIVE)
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
 (OPTION)
 (CONTAINS)
 (ENUM)
 (INTEGER)
 (MONEY)
 (POSITION)
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
 (TYPE)
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
 (DECIMAL_LITERAL)
 (MONEY_AMOUNT)
 (MODULE_DEF)
 (MODULE_USE)
 (MODULE_ALIAS)
 (MODULE_EXTERNAL)
 (COMBINE)
 (MAP_EACH)
 (TO)
 (INITIALLY)
 (IMPOSSIBLE)

 ; Identifiers
 (variable)
 (type_variable)
 (label)
 (state_label)
 (module_name)
 (scope_name)
 (field_name)
 (enum_struct_name)
 (constructor_name)
 (scope_var)
] @append_space

;; No space before a COMMA -- except when preceded by a numeric literal
;; FIXME: it only matters in catala_fr (e.g., 1+2,3 => would yield a parse error)
(typ_list
 (COMMA) @prepend_antispace)
(var_list
 (COMMA) @prepend_antispace)

(tuple_contents
 (_
  (literal
   [ (DECIMAL_LITERAL) (INT_LITERAL) ])? @do_nothing
   .)
 . (COMMA) @prepend_antispace)

(fun_arguments
 (COMMA) @prepend_antispace)
(rule_parameters
 (COMMA) @prepend_antispace)
(params_decl
 (COMMA) @prepend_antispace)

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
 (CONTENT) @prepend_spaced_softline @prepend_indent_start
 (typ) @append_spaced_softline
 ((DEPENDS) . (params_decl))*
 (DEFINED_AS)? @prepend_spaced_softline
) @append_indent_end @allow_blank_line_before

(params_decl) @prepend_indent_start @append_indent_end
(params_decl
 (param_decl)
 (COMMA) @append_spaced_softline
 (param_decl)
)

;; declaration items

(scope_decl_item) @append_hardline

(scope_decl_item
 (scope_decl_item_attribute) @append_indent_start
 (CONTENT) @prepend_spaced_softline
 (STATE)? @do_nothing
 (_) @append_indent_end
 .
)

(scope_decl_item                                         ;;
 (variable) @append_indent_start @append_spaced_softline ;;
 (SCOPE)                                                 ;;
 (qscope) @append_indent_end                             ;;
)                                                        ;;

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
  (scope_var) @append_indent_start @append_spaced_softline
  (STATE)
  (state_label) @append_spaced_softline @append_indent_end
)

(e_var_state
 (variable) @append_indent_start @append_spaced_softline
 (STATE)
 (state_label) @append_indent_end
)

;; generic variable definition
((LET)? @do_nothing
 (DEFINED_AS) @prepend_begin_scope
              @append_indent_start
              @append_spaced_scoped_softline
 body: (_) @append_indent_end @append_end_scope
 (#scope_id! "state_var_def")
)

;; multiline scope var definition

(scope
 (definition
   (DEFINITION) @prepend_begin_scope @append_indent_start @append_spaced_scoped_softline
   (scope_var) @append_spaced_scoped_softline
   [(UNDER_CONDITION) (STATE)]? @do_nothing
   (DEFINED_AS) @append_end_scope @append_spaced_scoped_softline @prepend_indent_end
 )
 (#scope_id! "scope_var_def")
)

;; conditional scope def
(scope
 (definition
   (DEFINITION)
   name: (scope_var)
   (UNDER_CONDITION) @append_spaced_softline @append_indent_start
   condition: (expression) @append_indent_end @append_spaced_softline
   (CONSEQUENCE)
 )
)

;; rules
(scope
 (rule
   (RULE)
   name: (scope_var)
   (UNDER_CONDITION) @append_spaced_softline @append_indent_start
   condition: (expression) @append_indent_end @append_spaced_softline
   (CONSEQUENCE) (NOT)? (FILLED) .
 )
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

(binder
 .
 (LPAREN) @append_antispace
 (RPAREN) @prepend_antispace
 .
 (#single_line_only!)
)

(typ
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

(binder
 .
 (LPAREN) @append_spaced_softline @append_indent_start
 (var_list
  (COMMA)? @append_input_softline
 )
 (RPAREN) @prepend_spaced_softline @prepend_indent_end
 .
)

(typ
 .
 (LPAREN) @append_spaced_softline @append_indent_start
 (typ_list
  (COMMA)? @append_input_softline
 )
 (RPAREN) @prepend_spaced_softline @prepend_indent_end
 .
)

;; Pattern-matching

(e_match . ((WITH_PATT) @append_spaced_softline) (_))

;; Pattern-matching cases

((ALT) . (match_case ((COLON) @prepend_space @append_spaced_softline @append_indent_start) (_) @append_indent_end .)) @prepend_spaced_softline

;; Let-bindings
(e_letin
 (LET) @prepend_begin_scope
 (binder)
 (DEFINED_AS) @append_indent_start @append_spaced_scoped_softline
 def: (_)
 (IN) @prepend_indent_end @append_end_scope @append_spaced_softline
 .
 body: (_)
 (#scope_id! "let-binding")
)

(e_letin
 def: (_)
 (IN) @prepend_input_softline
)

;; Pattern-tests

((e_test_match) @prepend_begin_scope           ;;
 [ (AND) (OR) (XOR) ] @prepend_spaced_softline ;;
 (_)  @append_end_scope                        ;;
 (#scope_id! "test_match")                     ;;
 )                                             ;;

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
 (BUT_REPLACE) @append_indent_start
 . (LBRACE) . (struct_content_fields) . (RBRACE) @append_indent_end @append_hardline
)

;; Fields accesses

((variable) (DOT) @prepend_antispace . (variable))

(e_fieldaccess (DOT) @prepend_antispace [(qfield) (TUPLE_INDEX)])

(qenum_struct (DOT) @prepend_antispace)
((qenum_struct) (DOT) @prepend_antispace)

(qconstructor
 (qenum_struct)
 (DOT) @prepend_antispace
 (constructor_name)
)

((variable) @append_indent_start
 (DOT) @prepend_antispace @append_input_softline
 . (variable) @append_indent_end
 (#multi_line_only!)
)

((module_name) (DOT) @prepend_antispace . (variable))
((module_name) (DOT) @prepend_antispace . (scope_name))

(e_fieldaccess
 (e_variable) @append_indent_start
 (DOT) @append_input_softline
 . (qfield) @append_indent_end
 (#multi_line_only!))

(qconstructor
 (qenum_struct) @append_indent_start
 (DOT) @append_input_softline
 . (constructor_name) @append_indent_end
 (#multi_line_only!)
)

;; TODO? should we close the indent later?

;; Struct expression

(
 (LBRACE) @append_spaced_scoped_softline @append_begin_scope @append_indent_start
 .
 (struct_content_fields)
 .
 (RBRACE) @prepend_spaced_scoped_softline @append_end_scope @prepend_indent_end
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
 (EXISTS)
 (binder)
 (AMONG)
 coll: (_) @append_indent_start @append_spaced_softline
 (SUCH)
 (THAT)
 cond: (_) @append_indent_end
 )

;; List For-all test

(e_coll_forall
 (FOR)
 (ALL)
 (binder)
 (AMONG)
 coll: (_) @append_indent_start @append_spaced_softline
 (WE_HAVE)
 cond: (_) @append_indent_end
)

;; List Mapping

(e_coll_map
 (MAP_EACH)
 (binder)
 (AMONG)
 coll: (_)
 (TO) @append_indent_start @append_spaced_softline
 mapf: (_) @append_indent_end
)

;; List Filter

(e_coll_filter
 (LIST)
 (OF)
 (_)
 (AMONG)
 coll: (_) @append_indent_start @append_spaced_softline
 (SUCH)
 (THAT)
 cond: (_) @append_indent_end
)

;; List Filter + Map

(e_coll_filter_map
 (MAP_EACH)
 (binder)
 (AMONG)
 coll: (_) @append_indent_start @append_spaced_softline
 (SUCH)
 (THAT)
 cond: (_) @append_indent_end @append_spaced_softline
 (TO) @append_indent_start @append_spaced_softline
 mapf: (_) @append_indent_end
)

;; List aggregation

((SUM) @prepend_begin_scope @append_indent_start
 (_)
 (OF) @prepend_spaced_scoped_softline @append_indent_end
 (e_coll_map . (_) @append_end_scope)
 (#scope_id! "aggregate")
)

;; List extremum

(e_coll_extremum
 [(MAXIMUM) (MINIMUM)]
 (OF)
 coll: (_) @append_indent_start @append_spaced_softline
 (OR)
 (IF)
 (LIST)
 (EMPTY)
 (THEN)
 dft: (_) @append_indent_end
)

;; List arg-extremum

(e_coll_arg_extremum
 (CONTENT)
 (OF)
 (_)
 (AMONG)
 coll: (_) @append_indent_start @append_spaced_softline
 (SUCH)
 (THAT)
 mapf: (_)
 (IS)
 [(MAXIMUM) (MINIMUM)] @append_spaced_softline
 (OR)
 (IF)
 (LIST)
 (EMPTY)
 (THEN)
 dft: (_) @append_indent_end
)

;; Amongs

((binder) @prepend_begin_scope
 (AMONG) @prepend_spaced_scoped_softline
 coll: (_) @append_end_scope
 (#scope_id! "among")
)

;; Fold

(e_coll_fold
 (COMBINE) @append_indent_start
 (ALL)
 (binder)
 (AMONG)
 coll: (_) @append_spaced_softline
 (IN)
 (binder)
 (INITIALLY) @prepend_input_softline
 acc: (_) @append_spaced_softline @append_begin_scope
 (WITH) @append_indent_start @append_input_softline
 mapf: (_) @append_indent_end @append_indent_end @append_end_scope
 (#scope_id! "fold")
)

;; Directives

(directive
 (BEGIN_DIRECTIVE)
 (LAW_INCLUDE)
 (COLON) @prepend_antispace @append_space
 (DIRECTIVE_ARG)
)

;; FIXME: I don't understand why the antispace is necessary...
(directive
 (BEGIN_DIRECTIVE)
 (MODULE_USE)
 (module_name) @append_antispace
 ((MODULE_ALIAS)
  (module_name))?
)

(directive
 (BEGIN_DIRECTIVE)
 (MODULE_DEF)
 (module_name) @append_antispace
 (MODULE_EXTERNAL)
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

(e_unop
 (MINUS) @append_antispace
)
