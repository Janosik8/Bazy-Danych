document.addEventListener('DOMContentLoaded', () => {
    
    // MOCK DATA: Symulacja odpowiedzi z widoków bazy PostgreSQL
    const mockTransactions = [
        {
            id: 1,
            title: "Hotel nad morzem",
            category: "Wakacje",
            date: "Dzisiaj, 14:30",
            amount: "- 250.00 PLN",
            icon: "fa-umbrella-beach",
            iconClass: "icon-transport" // orangeish
        },
        {
            id: 2,
            title: "[AUTO] Czynsz za mieszkanie",
            category: "Rachunki",
            date: "Wczoraj, 08:00",
            amount: "- 1,500.00 PLN",
            icon: "fa-house",
            iconClass: "icon-auto" // green
        },
        {
            id: 3,
            title: "Zakupy Biedronka",
            category: "Jedzenie",
            date: "15 Czerwca, 18:45",
            amount: "- 145.20 PLN",
            icon: "fa-cart-shopping",
            iconClass: "icon-food" // yellow
        }
    ];

    const mockBudgets = [
        {
            category: "Wakacje",
            spent: 550,
            planned: 500,
            percent: 110,
            class: "fill-danger"
        },
        {
            category: "Jedzenie",
            spent: 1200,
            planned: 1500,
            percent: 80,
            class: "fill-warning"
        }
    ];

    // RENDER: Ostatnie Transakcje
    const txList = document.getElementById('transactionList');
    mockTransactions.forEach(tx => {
        const li = document.createElement('li');
        li.className = 'tx-item';
        li.innerHTML = `
            <div class="tx-icon ${tx.iconClass}">
                <i class="fa-solid ${tx.icon}"></i>
            </div>
            <div class="tx-details">
                <div class="tx-title">${tx.title}</div>
                <div class="tx-date">${tx.category} • ${tx.date}</div>
            </div>
            <div class="tx-amount negative">${tx.amount}</div>
        `;
        txList.appendChild(li);
    });

    // RENDER: Wykorzystanie budżetów
    const budgetList = document.getElementById('budgetList');
    mockBudgets.forEach(b => {
        const div = document.createElement('div');
        div.className = 'budget-item';
        div.innerHTML = `
            <div class="b-header">
                <span class="b-title">${b.category}</span>
                <span class="b-amounts">${b.spent} / ${b.planned} PLN</span>
            </div>
            <div class="b-bar-bg">
                <div class="b-bar-fill ${b.class}" style="width: ${b.percent > 100 ? 100 : b.percent}%;"></div>
            </div>
        `;
        budgetList.appendChild(div);
    });

    // MODAL LOGIC
    const modal = document.getElementById('expenseModal');
    const openBtn = document.getElementById('addExpenseBtn');
    const closeBtn = document.getElementById('closeModalBtn');
    const form = document.getElementById('expenseForm');

    openBtn.addEventListener('click', () => {
        modal.classList.add('active');
    });

    closeBtn.addEventListener('click', () => {
        modal.classList.remove('active');
    });

    // Zamykanie przy kliknięciu w tło
    modal.addEventListener('click', (e) => {
        if(e.target === modal) {
            modal.classList.remove('active');
        }
    });

    // Obsługa formularza
    form.addEventListener('submit', (e) => {
        e.preventDefault();
        
        const btn = form.querySelector('button[type="submit"]');
        const originalText = btn.innerText;
        
        // Animacja przycisku i symulacja zapisu do bazy
        btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Zapisywanie...';
        btn.style.opacity = '0.8';

        setTimeout(() => {
            modal.classList.remove('active');
            btn.innerHTML = originalText;
            btn.style.opacity = '1';
            form.reset();
            
            // Animacja nowego rekordu
            alert("SQL INSERT wysłany do bazy! Trigger sprawdzi przekroczenie budżetu.");
        }, 800);
    });
});

    // NAVIGATION LOGIC
    const navItems = document.querySelectorAll('.nav-item[data-target]');
    const views = document.querySelectorAll('.view-section');

    navItems.forEach(item => {
        item.addEventListener('click', () => {
            // Remove active from all nav items
            navItems.forEach(nav => nav.classList.remove('active'));
            // Add active to clicked nav item
            item.classList.add('active');

            // Hide all views
            views.forEach(view => view.classList.remove('active'));
            
            // Show targeted view
            const targetId = item.getAttribute('data-target');
            document.getElementById(targetId).classList.add('active');
        });
    });

