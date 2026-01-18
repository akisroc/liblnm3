# Glossary (EN)

## Context: Sovereignty

| Term               | Business definition |
| :----------------- | :----------------   |
| **Kingdom**        | Political entity.   |
| **Fame**           | Fame mechanism.     |
| **Troop**          | Set of units.       |
| **Unit**           | Soldiers of a certain archetype |
| **Unit archetype** | Defines unit’s attributes (power, speed, kill rate, etc.) |

```mermaid
classDiagram
    namespace Sovereignty {
        class Kingdom {
            +Fame
            +Troop defense
            +Troop attack
            Create()
        }
        class Missive {
            +Content
            Send()
        }
        class Battle {
            +Log
            Solve()
        }
    }

    namespace Accounts {
        class User {
        	+Nickname
            +Email
        }
    }

    namespace Roleplay {
    	class Protagonist {
    		+Name
    	}
    }

    %% Semantical relations
    User         "1" -- "1"  Kingdom  :  Owns    >
    Protagonist  "1" -- "1"  Kingdom  :  Leads   >
    Kingdom      "1" -- "*"  Missive  :  Sends   >
    Kingdom      "1" -- "*"  Battle   :  Fights  >
    Kingdom      "1" -- "*"  Kingdom  :  Attacks >
```