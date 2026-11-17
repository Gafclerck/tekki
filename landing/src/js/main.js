/**
 * Tekki Landing Page — JavaScript Interactif
 * - Sélecteur d'écrans pour le simulateur de smartphone
 * - Accordéon interactif pour la FAQ
 * - Gestionnaire de clic Google Play Store (avec toast d'information sur le placeholder)
 */

document.addEventListener('DOMContentLoaded', () => {
  // 1. Définition des contenus des écrans mobiles (Inspirés directement des maquettes BMAD Tekki)
  const phoneScreens = {
    accueil: `
      <div class="app-header-mini">
        <img src="assets/branding/logo_horizontal.svg" alt="Tekki" height="20" style="height: 20px; width: auto;">
        <span class="app-date-mini">Mardi 17 Nov.</span>
      </div>
      <div class="cash-card-mini">
        <div class="cash-label-mini">Caisse du jour (Ventes)</div>
        <div class="cash-amount-mini">145 500 FCFA</div>
        <div class="cash-stats-mini">
          <div class="cash-stat-col">
            <div class="cash-stat-title">Transactions</div>
            <div class="cash-stat-value">28 ventes</div>
          </div>
          <div class="cash-stat-col">
            <div class="cash-stat-title">Dépenses</div>
            <div class="cash-stat-value">12 000 FCFA</div>
          </div>
        </div>
      </div>
      <div class="btn-cta-mini">+ Vente Rapide (2 clics)</div>
      <div class="debt-banner-mini">
        <div>
          <div class="debt-label-mini">Karné Bor (Argent dehors)</div>
          <div style="font-size: 11px; color: var(--secondary);">3 clients en retard</div>
        </div>
        <div class="debt-val-mini">48 000 F</div>
      </div>
      <div style="background: var(--surface); border: 1px solid var(--tertiary); border-radius: 12px; padding: 12px; font-size: 11px;">
        <div style="font-weight: 700; color: var(--primary); margin-bottom: 4px;">Conseiller Tekki (Conseil du jour)</div>
        <div style="color: var(--secondary);">"Amadou, vos rentrées de caisse du mardi sont stables. Pensez à relancer Modou pour ses 15 000 F."</div>
      </div>
    `,
    cloture: `
      <div class="app-header-mini">
        <span class="app-brand-mini">Clôture Express</span>
        <span class="app-date-mini">Étape du soir</span>
      </div>
      <div style="background: var(--surface); border: 1px solid var(--tertiary); border-radius: 14px; padding: 14px; margin-bottom: 12px;">
        <div style="font-size: 11px; font-weight: 700; color: var(--secondary); margin-bottom: 6px;">1. TOTAL DES VENTES</div>
        <div style="font-size: 20px; font-weight: 900; color: var(--primary);">145 500 FCFA</div>
      </div>
      <div style="background: var(--surface); border: 1px solid var(--tertiary); border-radius: 14px; padding: 14px; margin-bottom: 12px;">
        <div style="font-size: 11px; font-weight: 700; color: var(--secondary); margin-bottom: 6px;">2. DÉPENSES & RÉASSORT</div>
        <div style="font-size: 18px; font-weight: 800; color: #DC2626;">- 12 000 FCFA</div>
      </div>
      <div style="background: var(--surface); border: 1px solid var(--tertiary); border-radius: 14px; padding: 14px; margin-bottom: 14px;">
        <div style="font-size: 11px; font-weight: 700; color: var(--secondary); margin-bottom: 6px;">3. ESPÈCES EN TIROIR DÉCLARÉES</div>
        <div style="font-size: 20px; font-weight: 900; color: #16A34A;">133 500 FCFA</div>
        <div style="font-size: 10px; color: var(--secondary); margin-top: 4px;">Écart calculé : 0 FCFA (Caisse parfaite)</div>
      </div>
      <div class="btn-cta-mini" style="background-color: var(--primary); margin-bottom: 0;">Verrouiller la caisse (GPS Passif)</div>
    `,
    karnebor: `
      <div class="app-header-mini">
        <span class="app-brand-mini">Karné Bor</span>
        <span class="app-date-mini">Total : 48 000 F</span>
      </div>
      <div style="display: flex; flex-direction: column; gap: 8px;">
        <div style="background: var(--surface); border: 1px solid var(--tertiary); border-left: 4px solid #DC2626; border-radius: 10px; padding: 10px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 12px; font-weight: 800; color: var(--primary);">Modou Fall</div>
            <div style="font-size: 10px; color: #DC2626; font-weight: 600;">Retard 4 jours (Échéance 13 Nov)</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 13px; font-weight: 900; color: var(--primary);">15 000 F</div>
            <span style="font-size: 9px; background: #DCFCE7; color: #15803D; padding: 2px 6px; border-radius: 4px; font-weight: 700;">Relancer</span>
          </div>
        </div>
        <div style="background: var(--surface); border: 1px solid var(--tertiary); border-left: 4px solid #EAB308; border-radius: 10px; padding: 10px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 12px; font-weight: 800; color: var(--primary);">Fatou Diop</div>
            <div style="font-size: 10px; color: #CA8A04; font-weight: 600;">Échéance aujourd'hui</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 13px; font-weight: 900; color: var(--primary);">8 000 F</div>
            <span style="font-size: 9px; background: #DCFCE7; color: #15803D; padding: 2px 6px; border-radius: 4px; font-weight: 700;">Relancer</span>
          </div>
        </div>
        <div style="background: var(--surface); border: 1px solid var(--tertiary); border-left: 4px solid #16A34A; border-radius: 10px; padding: 10px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 12px; font-weight: 800; color: var(--primary);">Moussa Sow</div>
            <div style="font-size: 10px; color: var(--secondary);">Échéance dans 3 jours</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 13px; font-weight: 900; color: var(--primary);">25 000 F</div>
            <span style="font-size: 9px; background: #F1F5F9; color: var(--secondary); padding: 2px 6px; border-radius: 4px; font-weight: 700;">Détail</span>
          </div>
        </div>
      </div>
      <div style="margin-top: 10px; text-align: center; font-size: 10px; color: var(--secondary);">
        Taux de recouvrement moyen : <strong>88 %</strong>
      </div>
    `,
    passeport: `
      <div class="app-header-mini">
        <span class="app-brand-mini">Passeport Tekki</span>
        <span class="app-date-mini">Certifié 100% In-App</span>
      </div>
      <div style="background: var(--surface); border: 1px solid var(--tertiary); border-radius: 14px; padding: 14px; text-align: center; box-shadow: var(--shadow-sm);">
        <div style="font-size: 10px; text-transform: uppercase; font-weight: 700; color: var(--secondary);">Score de Fiabilité</div>
        <div style="font-size: 28px; font-weight: 900; color: var(--primary); margin: 2px 0;">88 <span style="font-size: 13px; color: var(--secondary);">/100</span></div>
        <div style="display: inline-block; font-size: 10px; background: #DEF7EC; color: #03543F; padding: 3px 10px; border-radius: 999px; font-weight: 700; margin-bottom: 10px;">Éligible Facilité Réassort</div>
        <div style="width: 120px; height: 120px; background: #F8FAFC; border: 1.5px dashed var(--secondary); border-radius: 8px; margin: 0 auto 8px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#133E59" stroke-width="1.8">
            <rect x="3" y="3" width="7" height="7" rx="1"/>
            <rect x="14" y="3" width="7" height="7" rx="1"/>
            <rect x="14" y="14" width="7" height="7" rx="1"/>
            <rect x="3" y="14" width="7" height="7" rx="1"/>
            <circle cx="6.5" cy="6.5" r="1.5" fill="#133E59"/>
            <circle cx="17.5" cy="6.5" r="1.5" fill="#133E59"/>
            <circle cx="6.5" cy="17.5" r="1.5" fill="#133E59"/>
            <circle cx="17.5" cy="17.5" r="1.5" fill="#133E59"/>
          </svg>
          <span style="font-size: 8px; font-weight: 700; color: var(--secondary); margin-top: 4px;">SCANNER POUR AUDIT</span>
        </div>
        <div style="font-size: 10px; color: var(--secondary); font-weight: 600;">Code PIN Temporaire : <strong style="color: var(--accent);">5821</strong></div>
      </div>
    `
  };

  // 2. Gestion du switch d'écran sur le simulateur mobile
  const screenContainer = document.getElementById('phone-screen-target');
  const controlButtons = document.querySelectorAll('.mockup-pill-btn');

  if (screenContainer && controlButtons.length > 0) {
    controlButtons.forEach(button => {
      button.addEventListener('click', () => {
        const targetScreen = button.getAttribute('data-screen');
        if (phoneScreens[targetScreen]) {
          controlButtons.forEach(btn => btn.classList.remove('active'));
          button.classList.add('active');

          screenContainer.style.opacity = '0';
          screenContainer.style.transform = 'translateY(6px)';

          setTimeout(() => {
            screenContainer.innerHTML = phoneScreens[targetScreen];
            screenContainer.style.transition = 'all 0.25s ease';
            screenContainer.style.opacity = '1';
            screenContainer.style.transform = 'translateY(0)';
          }, 150);
        }
      });
    });
  }

  // 3. Gestion de l'accordéon FAQ
  const faqQuestions = document.querySelectorAll('.faq-question');
  faqQuestions.forEach(question => {
    question.addEventListener('click', () => {
      const item = question.parentElement;
      const isOpen = item.classList.contains('open');

      // Ferme tous les autres éléments pour ne garder qu'un onglet ouvert à la fois
      document.querySelectorAll('.faq-item').forEach(otherItem => {
        otherItem.classList.remove('open');
      });

      if (!isOpen) {
        item.classList.add('open');
      }
    });
  });

  // 4. Gestion des boutons Google Play Store (Placeholder interactif)
  const playStoreButtons = document.querySelectorAll('[data-playstore-link]');
  const toast = document.getElementById('playstore-toast');

  playStoreButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      const url = btn.getAttribute('data-playstore-url') || btn.getAttribute('href');
      
      // Si l'URL est le placeholder temporaire
      if (!url || url === '#' || url === '#play-store') {
        e.preventDefault();
        showToast("L'application arrive très bientôt sur Google Play Store ! Le lien officiel sera activé lors de la publication.");
      }
    });
  });

  function showToast(message) {
    if (!toast) return;
    const msgElem = toast.querySelector('.toast-msg');
    if (msgElem) msgElem.textContent = message;
    toast.classList.add('show');

    setTimeout(() => {
      toast.classList.remove('show');
    }, 4500);
  }
});
