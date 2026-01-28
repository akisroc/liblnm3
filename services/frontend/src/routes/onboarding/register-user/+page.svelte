<script lang="ts">
  import { enhance } from '$app/forms';
  // import type { ActionData } from './$types';
  //
  // export let form: ActionData;
</script>

<form class="onboarding-form" method="POST" action="?/register_user" use:enhance>
  <fieldset>
    <legend>Inscription</legend>
<!--    <input type="text" id="nickname" name="nickname" required>-->
    <input type="text" id="nickname" name="nickname">
    <label for="nickname">Nom d'utilisateur</label>
<!--    <input class="error" type="email" id="email" name="email" required>-->
    <input class="error" type="email" id="email" name="email">
    <label for="email">Adresse e-mail</label>
<!--    <input class="success" type="password" id="password" name="password" required>-->
    <input class="success" type="password" id="password" name="password">
    <label for="password">Mot de passe</label>
  </fieldset>
  <button type="submit">C’est parti</button>
</form>
