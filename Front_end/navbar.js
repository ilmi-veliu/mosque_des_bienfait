document.addEventListener('DOMContentLoaded', function() {
    const navbarHTML = `
      <header>
        <nav class="navbar">
          <div class="logo">Mosquée des Bienfaisants</div>
          <ul class="nav-links">
            <li><a href="index.html">Accueil</a></li>
            <li><a href="inscription.html">S'inscrire</a></li>
            <li><a href="contact.html">Contact Imam</a></li>
            <li><a href="evenements.html">Événements</a></li>
            <li><a href="horaires.html">Horaires</a></li>
          </ul>
        </nav>
      </header>
    `;
    
    const container = document.getElementById('navbar-container');
    if (container) {
      container.innerHTML = navbarHTML;
    }
  });