document.addEventListener('DOMContentLoaded', function() {
    const footerHTML = `
      <footer class="footer">
        <div class="footer-container">
          <div class="footer-col">
            <h3>Mosquée des Bienfaisants</h3>
            <p>Un lieu de paix, de spiritualité et de communauté au service des musulmans de Périgueux et de tous ceux qui souhaitent découvrir l'Islam.</p>
          </div>
          <div class="footer-col">
            <h3>Contact</h3>
            <p>📍 Mosquée Perigueux - مسجد, 18 Rue du Tennis, 24000 Périgueux</p>
            <p>📞 05 53 35 14 27</p>
            <p>📧 Email à mettre ici</p>
          </div>
          <div class="footer-col">
            <h3>Horaires d'Ouverture</h3>
            <p>Ouvert tous les jours pour les prières<br>20 minutes avant et après la prière</p>
          </div>
          <div class="footer-col">
            <h3>Liens Rapides</h3>
            <ul>
              <li><a href="index.html">Accueil</a></li>
              <li><a href="#">Contacter l'Imam</a></li>
              <li><a href="#">Événements</a></li>
              <li><a href="#">Horaires des Prières</a></li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <p>&copy; 2025 Mosquée des Bienfaisants. Tous droits réservés.</p>
          <p>Site créé avec respect et dévouement pour servir notre communauté</p>
        </div>
      </footer>
    `;
    
    document.getElementById('footer-container').innerHTML = footerHTML;
  });