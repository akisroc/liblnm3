# LNM3 coding style conventions

## Variable naming

### Words

Prioritize expressive names, even if they get long. Better long
easy-to-read multilines instructions than cryptic oneliners.

Prefer full words rather than shortened versions. But stay
reasonable, a variable name shouldn’t exceed 25 characters.

Some exceptions are widely recognized shortened words:

```elixir
msg   = "message"
str   = "string"
txt   = "text"
nb    = "number"
err   = "error"
req   = "request"
res   = "result"
repo  = "repository"
infra = "infrastructure"
app   = "application"
nsfw  = "not safe for work"
db    = "database"
env   = "environment"
dev   = "development"
prod  = "production"
```

These are OK, especially if they significantly improve code
flow. But even with these words, if the code block is simple
and conciseness is not a big stake, `message` remains
more natural to read than `msg`.

In LNM core domains, we also go for these:

```elixir
atk = "attack"
def = "defense"
rp  = "roleplay"
```

Context matters.

### Letters

Single letters as variables names should be avoided.

We can make an exception in very simple straightforward
functions of one to a few lines, and not implying a large
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
a user, and as this `u` thing is locked up in a very
straightforward oneline guard that developers don’t need
to read often. Fully writing `user` wouldn’t help much
in this case; it would just make the line longer without
achieving anything.
