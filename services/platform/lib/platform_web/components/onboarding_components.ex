defmodule PlatformWeb.OnboardingComponents do
  @moduledoc false
  use PlatformWeb, :html

  @doc """
  STEP 1
  User registration
  """
  attr :nickname, :string, required: true
  attr :email, :string, required: true
  attr :password, :string, required: true

  def user_form(assigns) do
    ~H"""
    <form class="onboarding-form" hx-post={~p"/register-user"} hx-swap="outerHTML">
      <fieldset>
        <legend>Inscription</legend>

        <input type="text" id="nickname" name="nickname">
        <label for="nickname">Nom d'utilisateur</label>

        <input class="error" type="email" id="email" name="email">
        <label for="email">Adresse e-mail</label>

        <input class="success" type="password" id="password" name="password">
        <label for="password">Mot de passe</label>
      </fieldset>
      <button type="submit">C’est parti</button>
    </form>
    """
  end

  @doc """
  STEP 2
  Kingdom and leader registration
  """
  attr :kingdom_name, :string, required: true
  attr :leader_name, :string, required: true

  def kingdom_and_leader_form(assigns) do
    ~H"""
    <form hx-post={~p"/register-kingdom-and-leader"} hx-swap="outerHTML">
        <legend>Royaume</legend>

        <input type="text" id="kingdom_name" name="kingdom_name">
        <label for="kingdom_name">Nom de votre royaume</label>

        <input type="text" id="leader_name" name="leader_name">
        <label for="leader_name">Nom du leader de votre royaume</label>

        <button type="submit">Terminer</button>
    </form>
    """
  end
end
