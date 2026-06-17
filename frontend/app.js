document.addEventListener('DOMContentLoaded', () => {
    
    // NAVIGATION LOGIC
    const navItems = document.querySelectorAll('.nav-item[data-target]');
    const views = document.querySelectorAll('.view-section');

    navItems.forEach(item => {
        item.addEventListener('click', () => {
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
            views.forEach(view => view.classList.remove('active'));
            const targetId = item.getAttribute('data-target');
            document.getElementById(targetId).classList.add('active');
        });
    });

    // MOCK DATA: SYMULACJA ZABEZPIECZEŃ ROW LEVEL SECURITY (RLS)
    const dbMock = {
        "1": { // Household 1: Rodzina Kowalskich
            name: "Jan Kowalski",
            balance: "+ 2,450.00 PLN",
            totalIncomes: "8,500 PLN",
            totalExpenses: "6,050 PLN",
            transactions: [
                { id: 101, title: "Hotel nad morzem", category: "Wakacje", date: "Dzisiaj, 14:30", amount: "- 250.00 PLN", type: "expense" },
                { id: 102, title: "[AUTO] Czynsz za mieszkanie", category: "Rachunki", date: "Wczoraj, 08:00", amount: "- 1,500.00 PLN", type: "expense" },
                { id: 103, title: "Wypłata", category: "Pensja", date: "10 Czerwca", amount: "+ 8,500.00 PLN", type: "income" },
                { id: 104, title: "Zakupy Biedronka", category: "Jedzenie", date: "05 Czerwca", amount: "- 400.00 PLN", type: "expense" }
            ],
            budgets: [
                { category: "Wakacje", spent: 4800, planned: 5000, percent: 96, class: "fill-warning" },
                { category: "Jedzenie", spent: 1200, planned: 1500, percent: 80, class: "fill-warning" }
            ],
            goals: [
                { title: "Nowy Samochód", progress: "31.2%", amount: "15,000 / 48,000" },
                { title: "Remont łazienki", progress: "80.0%", amount: "8,000 / 10,000" }
            ],
            reports: [
                { month: "Styczeń", bal: "+ 1,200 PLN" }, { month: "Luty", bal: "+ 500 PLN" }, 
                { month: "Marzec", bal: "- 200 PLN" }, { month: "Kwiecień", bal: "+ 2,100 PLN" }
            ],
            categories: [
                { name: "Jedzenie", type: "expense", scope: "global" },
                { name: "Rachunki", type: "expense", scope: "global" },
                { name: "Pensja", type: "income", scope: "global" },
                { name: "Zwierzęta (Pies)", type: "expense", scope: "local" },
                { name: "Zajęcia Dodatkowe (Dzieci)", type: "expense", scope: "local" }
            ]
        },
        "2": { // Household 2: Konto Studenckie
            name: "Student Nowak",
            balance: "- 150.00 PLN",
            totalIncomes: "1,200 PLN",
            totalExpenses: "1,350 PLN",
            transactions: [
                { id: 201, title: "Bilet miesięczny MZK", category: "Transport", date: "Dzisiaj, 09:15", amount: "- 60.00 PLN", type: "expense" },
                { id: 202, title: "Piwo w barze", category: "Rozrywka", date: "Wczoraj, 22:30", amount: "- 40.00 PLN", type: "expense" },
                { id: 203, title: "Kieszonkowe od mamy", category: "Kieszonkowe", date: "12 Czerwca", amount: "+ 1,200.00 PLN", type: "income" },
                { id: 204, title: "Czynsz akademik", category: "Rachunki", date: "01 Czerwca", amount: "- 600.00 PLN", type: "expense" }
            ],
            budgets: [
                { category: "Rozrywka", spent: 450, planned: 300, percent: 150, class: "fill-danger" },
                { category: "Transport", spent: 60, planned: 100, percent: 60, class: "fill-warning" }
            ],
            goals: [
                { title: "Wyjazd w góry", progress: "10.0%", amount: "100 / 1,000" }
            ],
            reports: [
                { month: "Styczeń", bal: "- 50 PLN" }, { month: "Luty", bal: "+ 10 PLN" }, 
                { month: "Marzec", bal: "- 100 PLN" }, { month: "Kwiecień", bal: "- 10 PLN" }
            ],
            categories: [
                { name: "Jedzenie", type: "expense", scope: "global" },
                { name: "Rachunki", type: "expense", scope: "global" },
                { name: "Pensja", type: "income", scope: "global" },
                { name: "Rozrywka (Kluby)", type: "expense", scope: "local" },
                { name: "Kieszonkowe", type: "income", scope: "local" },
                { name: "Materiały na studia", type: "expense", scope: "local" }
            ]
        }
    };

    let currentHouseholdId = '1';

    // RENDER LOGIC
    function renderApp() {
        const data = dbMock[currentHouseholdId];
        
        // Header
        document.getElementById('sidebarName').innerText = data.name;
        document.getElementById('currentRlsVar').innerText = currentHouseholdId;
        
        // Pulpit Overview
        document.getElementById('monthlyBalance').innerText = data.balance;
        document.getElementById('monthlyBalance').className = 'amount ' + (data.balance.includes('-') ? 'negative' : 'positive');
        document.getElementById('totalIncomes').innerText = data.totalIncomes;
        document.getElementById('totalExpenses').innerText = data.totalExpenses;

        // Transactions (Top 3 on Dashboard)
        const txList = document.getElementById('transactionList');
        txList.innerHTML = '';
        data.transactions.slice(0, 3).forEach(tx => {
            const isInc = tx.type === 'income';
            txList.innerHTML += `
                <li class="tx-item">
                    <div class="tx-icon ${isInc ? 'icon-auto' : 'icon-food'}">
                        <i class="fa-solid ${isInc ? 'fa-arrow-down' : 'fa-arrow-up'}"></i>
                    </div>
                    <div class="tx-details">
                        <div class="tx-title">${tx.title}</div>
                        <div class="tx-date">${tx.category} • ${tx.date}</div>
                    </div>
                    <div class="tx-amount ${isInc ? 'positive' : 'negative'}">${tx.amount}</div>
                </li>
            `;
        });

        // Full Transactions Table
        const fullTable = document.getElementById('fullTransactionsTable');
        fullTable.innerHTML = '';
        data.transactions.forEach(tx => {
            fullTable.innerHTML += `
                <tr>
                    <td>#${tx.id}</td>
                    <td>${tx.date}</td>
                    <td>${tx.type === 'income' ? '<span style="color:var(--success)">Przychód</span>' : '<span style="color:var(--danger)">Wydatek</span>'}</td>
                    <td>${tx.category}</td>
                    <td>${tx.title}</td>
                    <td style="text-align:right;" class="${tx.type === 'income' ? 'positive' : 'negative'}">${tx.amount}</td>
                </tr>
            `;
        });

        // Budgets on Dashboard
        const budgetList = document.getElementById('budgetList');
        budgetList.innerHTML = '';
        data.budgets.forEach(b => {
            budgetList.innerHTML += `
                <div class="budget-item">
                    <div class="b-header">
                        <span class="b-title">${b.category}</span>
                        <span class="b-amounts">${b.spent} / ${b.planned} PLN</span>
                    </div>
                    <div class="b-bar-bg">
                        <div class="b-bar-fill ${b.class}" style="width: ${b.percent > 100 ? 100 : b.percent}%;"></div>
                    </div>
                </div>
            `;
        });

        // Goals View
        const goalsContainer = document.getElementById('goalsContainer');
        goalsContainer.innerHTML = '';
        data.goals.forEach(g => {
            goalsContainer.innerHTML += `
                <div class="card glass-panel" style="padding:20px;">
                    <div class="card-header"><h3><i class="fa-solid fa-crosshairs"></i> ${g.title}</h3></div>
                    <div class="card-body">
                        <div class="progress-info" style="margin-top:15px;">
                            <span class="progress-val">${g.progress}</span>
                            <span class="progress-target">${g.amount} PLN</span>
                        </div>
                        <div class="progress-bar-container">
                            <div class="progress-fill" style="width: ${g.progress};"></div>
                        </div>
                    </div>
                </div>
            `;
        });

        // Reports View
        const reportsGrid = document.getElementById('reportsGrid');
        reportsGrid.innerHTML = '';
        data.reports.forEach(r => {
            const isNeg = r.bal.includes('-');
            reportsGrid.innerHTML += `
                <div class="report-card">
                    <h4>${r.month}</h4>
                    <div class="bal" style="color: ${isNeg ? 'var(--danger)' : 'var(--success)'};">${r.bal}</div>
                </div>
            `;
        });

        // Categories View
        const catContainer = document.getElementById('categoriesContainer');
        catContainer.innerHTML = '';
        data.categories.forEach(c => {
            catContainer.innerHTML += `
                <div class="cat-item ${c.scope}">
                    <div>
                        <strong style="font-size:1.1rem; margin-right:10px;">${c.name}</strong>
                        <span style="color:var(--text-muted); font-size:0.85rem;">[${c.type === 'income' ? 'Przychód' : 'Wydatek'}]</span>
                    </div>
                    <div class="cat-badge ${c.scope}">${c.scope === 'global' ? 'SYSTEMOWA' : 'LOKALNA'}</div>
                </div>
            `;
        });
        
        // Reset Alerts
        document.getElementById('budgetAlert').style.display = 'none';
        document.getElementById('alertBadge').innerText = '0';
    }

    // SELECTOR LISTENER (Symulacja RLS)
    document.getElementById('householdSelector').addEventListener('change', (e) => {
        currentHouseholdId = e.target.value;
        renderApp();
    });

    // INITIAL RENDER
    renderApp();

    // MOCK ADD EXPENSE
    const modal = document.getElementById('expenseModal');
    document.getElementById('addExpenseBtn').addEventListener('click', () => modal.classList.add('active'));
    document.getElementById('closeModalBtn').addEventListener('click', () => modal.classList.remove('active'));
    
    document.getElementById('expenseForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const amt = parseFloat(document.getElementById('formAmount').value);
        const cat = document.getElementById('formCategory').value;
        const btn = document.querySelector('#expenseForm button');
        
        btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Wykonywanie zapytania...';
        
        setTimeout(() => {
            modal.classList.remove('active');
            btn.innerHTML = 'INSERT INTO expenses...';
            document.getElementById('expenseForm').reset();
            
            // Symulacja zadziałania triggera budget_alerts (jeśli dużo wydajemy)
            if(amt > 200) {
                document.getElementById('budgetAlert').style.display = 'flex';
                document.getElementById('alertMessage').innerText = `Wydatki w kategorii "${cat}" przekroczyły bezpieczny próg zaplanowanego budżetu!`;
                document.getElementById('alertBadge').innerText = '1';
                document.getElementById('budgetAlert').style.animation = 'none';
                setTimeout(() => document.getElementById('budgetAlert').style.animation = '', 10);
            } else {
                alert("Wpis wprowadzony do tabeli. Brak alertów z bazy.");
            }
        }, 600);
    });

    // MOCK ADD CATEGORY
    const catModal = document.getElementById('categoryModal');
    document.getElementById('addCategoryBtn').addEventListener('click', () => catModal.classList.add('active'));
    document.getElementById('closeCatModalBtn').addEventListener('click', () => catModal.classList.remove('active'));

    document.getElementById('categoryForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const catName = document.getElementById('formCatName').value;
        const catType = document.getElementById('formCatType').value;
        const btn = document.querySelector('#categoryForm button');
        
        btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Wykonywanie...';
        
        setTimeout(() => {
            catModal.classList.remove('active');
            btn.innerHTML = 'INSERT INTO categories';
            document.getElementById('categoryForm').reset();
            
            // Dopisz do struktury i wyrenderuj ponownie
            dbMock[currentHouseholdId].categories.push({
                name: catName,
                type: catType,
                scope: "local"
            });
            renderApp();
            
        }, 500);
    });

    // MOCK PROCEDURE
    document.getElementById('callProcedureBtn').addEventListener('click', (e) => {
        const btn = e.target;
        const originalText = btn.innerHTML;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Wykonywanie w tle...';
        setTimeout(() => {
            btn.innerHTML = '<i class="fa-solid fa-check"></i> Procedura wywołana!';
            setTimeout(() => btn.innerHTML = originalText, 2000);
        }, 1000);
    });

});
