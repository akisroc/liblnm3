# LNM3 coding conventions


## English language

English is to be used everywhere in this repository: code, comments,
documentation, issues, etc.

Only specs may be written in french, since this LNM founds itself on a
french-speaking, but these are in a distinct repository.


## Namings


### Style

* `PascalCase` for modules (ex: `Sovereignty.WarEngine`)
* `snake_case` for everything else, from variables to functions,
  including folders and modules files (ex: `sovereignty/war_engine.ex`)


### Words

Prioritize expressive names, even if they get a bit long. Better
long easy-to-read multilines instructions than cryptic oneliners.

Prefer full words rather than shortened versions. But stay
reasonable, a variable name shouldn’t exceed 25 characters.

This rule doesn’t necessarily apply to widely recognized
shorters, especially if they significantly improve code flow.

```elixir
✅ msg   = "message"
✅ str   = "string"
✅ txt   = "text"
✅ nb    = "number"
✅ err   = "error"
✅ req   = "request"
✅ res   = "result"
✅ repo  = "repository"
❌ sctr  = "structure"
❌ mntc  = "maintenance"
❌ tbl   = "table"
❌ tst   = "test"
❌ nme   = "name"
❌ atps  = "attempts"
```

Not exhaustive but you get the point.

Note that even with shortenable words, if the code block
is simple and conciseness is not a big stake, `message`
remains more natural to read than `msg`.

In LNM core domains, we also go for these:

```elixir
✅ atk = "attack"
✅ def = "defense"
✅ rp  = "roleplay"
```

Context and common sense matter. Furthermore, `atk` and `def`
find themselves in the battle engine, in the heart of LNM’s
fighting system mathematics, where conciseness and expressiveness
is killer. Writing `attacker` and `defender` would in fact harm
the flow in most cases for no benefit.

Be smart.


### Letters

Single letters as variables names should be avoided.

We can make an exception in very simple straightforward
functions of one to a few lines, which don’t imply a large
number of other variables. In this cases, and when context
makes things very clear, let’s say OK for these:

* `s` for a string
* `a`, `b` and `c` for 2 to 3 strings interacting
* `n` for a number
* `x`, `y` and `z` for 2 to 3 numbers interacting
* `t` for a type
* `f` for a file

In some specific contexts, like straightforward anonymous
function or guards, you can allow yourself to use some
arbitrary letters in cases where conciseness helps
readability rather than the contrary. Example:


```elixir
def can_see_nsfw?(%User{} = u) when u.age >= 18, do: true
```

This is OK as this is very clear that we are talking about
a user, and this `u` thing is locked up in a very
straightforward oneline guard that developers don’t need
to read often. Fully writing `user` wouldn’t help much
in this case; it would just make the line longer without
achieving anything.


## Indentation

2 spaces.

Since we promote expressive names, potentially long ones,
we have to keep indentation short to avoid too many line
wraps. We can’t afford 4 spaces indentation.

No tabs, only spaces. This allows to align some statements
with precision, like `with` successive matches:


```elixir
with {:ok, atk_kingdom} <- SovereigntyRepo.get_kingdom(atk_kingdom_id),
     {:ok, def_kingdom} <- SovereigntyRepo.get_kingdom(def_kingdom_id),
     # …
```

This is encouraged, and wouldn’t be possible with tabs.
