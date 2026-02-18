defmodule PlatformWeb.SplashpageComponents do
  @moduledoc false
  use PlatformWeb, :html

  def splashpage(assigns) do
    ~H"""
    <main class="splash">
        <h1>
            <span class="blur-reveal">A</span><%!--
            --%><span class="blur-reveal">k</span><%!--
            --%><span class="blur-reveal">i</span><%!--
            --%><span class="blur-reveal">s</span><%!--
            --%><span class="blur-reveal">r</span><%!--
            --%><span class="blur-reveal">o</span><%!--
            --%><span class="blur-reveal">c</span>
        </h1>
        <h2 class="smoke-reveal">Jeu de Rôles et de Conquêtes</h2>
        <nav class="smoke-reveal">
            <a href={~p"/onboarding/register-user"} class="register">Inscription</a>
            <a href="#" class="login">Connexion</a>
        </nav>

        <div aria-hidden="true" class="fog">
           	<div>Lorem ipsum dolor sit.</div>
           	<div>Lorem, ipsum.</div>
           	<div>Lorem.</div>
           	<div>Lorem ipsum, dolor sit amet, consectetur adipisicing elit. Quaerat blanditiis fuga nam molestias a earum deleniti obcaecati at? Voluptatem, iste. Quia, autem!</div>
           	<div>Lorem ipsum dolor sit amet consectetur adipisicing elit. Eum reprehenderit, architecto aspernatur?</div>
           	<div>Lorem ipsum dolor sit amet consectetur adipisicing elit. Explicabo doloribus expedita sunt, eius quasi.</div>
           	<div>Lorem ipsum dolor sit amet consectetur adipisicing elit. Animi tenetur eaque explicabo corporis et eius necessitatibus aliquam assumenda omnis exercitationem rerum deleniti facilis, impedit.</div>
           	<div>Lorem, ipsum dolor sit amet consectetur.</div>
           	<div>Lorem ipsum dolor sit amet consectetur adipisicing elit. Cum, esse commodi libero.</div>
           	<div>Lorem ipsum, dolor sit amet consectetur adipisicing, elit. Inventore odio accusantium nesciunt amet. Dicta, expedita maiores architecto ullam sapiente sit numquam labore nostrum amet ut eveniet tenetur asperiores! Placeat nesciunt ipsa laboriosam molestiae quibusdam ullam consectetur ipsum deserunt culpa. Quidem.</div>
           	<div>Lorem, ipsum, dolor.</div>
           	<div>Lorem.</div>
           	<div>Lorem ipsum dolor sit, amet consectetur adipisicing, elit. Distinctio, quos, facilis! Ratione facere veniam, sint nulla ipsum vitae culpa, expedita labore maxime, cum laudantium ad non? Culpa ad consequatur a.</div>
           	<div>Lorem, ipsum.</div>
           	<div>Lorem ipsum dolor sit amet consectetur adipisicing elit. Modi enim labore porro dolores, voluptates reiciendis corrupti praesentium, iusto sapiente quo.</div>
           	<div>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Magnam, aliquid accusamus, debitis totam placeat dolorum cum! Obcaecati perspiciatis accusantium est?</div>
           	<div>Lorem ipsum, dolor.</div>
           	<div>Lorem ipsum dolor sit amet consectetur, adipisicing elit. Vero aut fugit repellendus numquam quos.</div>
           	<div>Lorem, ipsum.</div>
           	<div>Lorem, ipsum dolor sit amet consectetur adipisicing elit. Nisi porro vitae distinctio expedita numquam, soluta nostrum voluptatibus deserunt mollitia ullam sunt. Consequatur aut iure quas porro molestiae iusto ipsa, eligendi.</div>
        </div>
    </main>
    """
  end
end
