<template>
  <div class="app-container">
    <header class="page-header">
      <h1 class="title-decoration">双色球生成器</h1>
      <p class="text-muted"></p>
    </header>

    <main>
      <div class="row">
        <div class="col-lg-12">
          <div class="lottery-card">
            <h2 class="text-center mb-4">今日幸运号码</h2>
            
            <div class="ball-container">
              <!-- Use index as key for simplicity during full replacement -->
              <!-- Temporarily remove animated-ball class to test disappearance issue -->
              <div v-for="(ball, index) in redBalls" :key="index" 
                   class="lottery-ball red-ball">
                {{ ball }}
              </div>
              <!-- Use index as key for simplicity during full replacement -->
              <!-- Temporarily remove animated-ball class to test disappearance issue -->
              <div v-for="(ball, index) in blueBalls" :key="index"
                   class="lottery-ball blue-ball">
                {{ ball }}
              </div>
            </div>
            
            <div class="d-flex justify-content-center gap-3 mt-4">
              <button @click="generateNumbers" class="btn btn-generate">
                <i class="bi bi-shuffle me-2"></i>生成号码
              </button>
              <button @click="saveNumbers" class="btn btn-save" :disabled="!hasGeneratedNumbers">
                <i class="bi bi-bookmark-plus me-2"></i>保存
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="row mt-5">
        <div class="col-lg-12">
          <div class="stats-container">
            <h3 class="mb-4">生成历史</h3>
            <div class="table-responsive">
              <table class="table history-table" v-if="savedResults.length > 0">
                <thead>
                  <tr>
                    <th scope="col">#</th>
                    <th scope="col">红球</th>
                    <th scope="col">蓝球</th>
                    <th scope="col">时间</th>
                    <th scope="col"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(result, index) in savedResults" :key="index">
                    <td>{{ index + 1 }}</td>
                    <td style="white-space: nowrap;">
                      <div v-for="ball in result.redBalls" :key="ball" 
                           class="lottery-ball red-ball history-ball d-inline-flex me-1">
                        {{ ball }}
                      </div>
                    </td>
                    <td>
                      <div class="lottery-ball blue-ball history-ball">
                        {{ result.blueBall }}
                      </div>
                    </td>
                    <td style="white-space: nowrap;">{{ formatDate(result.timestamp) }}</td>
                    <td>
                      <button @click="deleteResult(index)" class="btn btn-sm btn-outline-danger" aria-label="Delete result" title="Delete">
                        <i class="bi bi-trash"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
              <p v-else class="text-muted text-center">尚无保存结果</p>
            </div>
          </div>
        </div>

        <div class="col-lg-12 mt-5">
          <div class="stats-container">
            <h3 class="mb-4">号码统计</h3>
            <div v-if="savedResults.length > 0">
              <!-- Red Ball Chart -->
              <h5>红球频率</h5>
              <div class="chart-container mb-4">
                <div v-for="(freq, number) in sortedRedFrequency" :key="`red-${number}`" class="bar-item">
                  <span class="bar-label">{{ freq }}</span>
                  <div class="bar red-bar" :style="{ height: `${(freq / maxRedFrequency) * 100}px` }"></div>
                  <span class="bar-label number-label">{{ number }}</span>
                </div>
              </div>

              <!-- Blue Ball Chart -->
              <h5 class="mt-4">蓝球频率</h5>
              <div class="chart-container">
                 <div v-for="(freq, number) in sortedBlueFrequency" :key="`blue-${number}`" class="bar-item">
                  <span class="bar-label">{{ freq }}</span>
                  <div class="bar blue-bar" :style="{ height: `${(freq / maxBlueFrequency) * 100}px` }"></div>
                  <span class="bar-label number-label">{{ number }}</span>
                </div>
              </div>
            </div>
            <p v-else class="text-muted text-center">尚无统计数据</p>
          </div>
        </div>
      </div>
    </main>

    <footer class="footer">
      <p>© {{ currentYear }} 双色球模拟生成器</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      redBalls: [],
      blueBalls: [],
      savedResults: [],
      hasGeneratedNumbers: false,
      currentYear: new Date().getFullYear()
    }
  },
  computed: {
    redBallFrequency() {
      const frequency = {};
      
      // Initialize all possible red ball numbers (1-33)
      for (let i = 1; i <= 33; i++) {
        frequency[i] = 0;
      }
      
      // Count occurrences
      this.savedResults.forEach(result => {
        result.redBalls.forEach(ball => {
          frequency[ball]++;
        });
      });
      
      // Filter out zero-frequency numbers and sort by frequency (descending)
      return Object.fromEntries(
        Object.entries(frequency)
          .filter(([_, freq]) => freq > 0)
          .sort(([_, a], [__, b]) => b - a)
      );
    },
    
    blueBallFrequency() {
      const frequency = {};
      
      // Initialize all possible blue ball numbers (1-16)
      for (let i = 1; i <= 16; i++) {
        frequency[i] = 0;
      }
      
      // Count occurrences
      this.savedResults.forEach(result => {
        frequency[result.blueBall]++;
      });
      
      // Filter out zero-frequency numbers and sort by frequency (descending)
      return Object.fromEntries(
        Object.entries(frequency)
          .filter(([_, freq]) => freq > 0)
          .sort(([_, a], [__, b]) => b - a)
      );
    },
    
    maxRedFrequency() {
      // Find the maximum frequency among the red balls
      const allRedFrequencies = Object.values(this.redBallFrequency);
      return allRedFrequencies.length > 0 ? Math.max(...allRedFrequencies) : 1;
    },
    
    maxBlueFrequency() {
      // Find the maximum frequency among the blue balls
      const allBlueFrequencies = Object.values(this.blueBallFrequency);
      return allBlueFrequencies.length > 0 ? Math.max(...allBlueFrequencies) : 1;
    },
    
    // Keep this for backward compatibility if needed elsewhere
    maxFrequency() {
      return Math.max(this.maxRedFrequency, this.maxBlueFrequency);
    }
  },
  methods: {
    generateNumbers() {
      // Clear previous results
      this.redBalls = [];
      this.blueBalls = [];
      this.hasGeneratedNumbers = false;
      
      // Generate 6 unique red balls (1-33)
      const redBallsSet = new Set();
      while (redBallsSet.size < 6) {
        redBallsSet.add(Math.floor(Math.random() * 33) + 1);
      }
      // Sort red balls in ascending order
      this.redBalls = [...redBallsSet].sort((a, b) => a - b);
      
      // Generate 1 blue ball (1-16)
      this.blueBalls = [Math.floor(Math.random() * 16) + 1];
      
      this.hasGeneratedNumbers = true;
    },
    
    saveNumbers() {
      if (!this.hasGeneratedNumbers) return;
      
      const result = {
        redBalls: [...this.redBalls],
        blueBall: this.blueBalls[0],
        timestamp: new Date()
      };
      
      this.savedResults.unshift(result);
      
      // Save to local storage
      localStorage.setItem('doubleColorBallHistory', JSON.stringify(this.savedResults));
    },
    
    deleteResult(index) {
      this.savedResults.splice(index, 1);
      localStorage.setItem('doubleColorBallHistory', JSON.stringify(this.savedResults));
    },
    
    formatDate(dateString) {
      const date = new Date(dateString);
      return new Intl.DateTimeFormat('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      }).format(date);
    },
    
    loadSavedResults() {
      const saved = localStorage.getItem('doubleColorBallHistory');
      if (saved) {
        try {
          this.savedResults = JSON.parse(saved);
        } catch (e) {
          console.error('Error loading saved results', e);
          localStorage.removeItem('doubleColorBallHistory');
        }
      }
    }
  },
  mounted() {
    this.loadSavedResults();
    this.generateNumbers();
  },
  computed: {
    // ... (keep existing computed properties: redBallFrequency, blueBallFrequency, maxRedFrequency, maxBlueFrequency, maxFrequency) ...
    redBallFrequency() {
      const frequency = {};
      for (let i = 1; i <= 33; i++) { frequency[i] = 0; }
      this.savedResults.forEach(result => {
        result.redBalls.forEach(ball => { frequency[ball]++; });
      });
      return Object.fromEntries(
        Object.entries(frequency).filter(([_, freq]) => freq > 0)
        // Keep unsorted for chart display by number
      );
    },
    blueBallFrequency() {
      const frequency = {};
      for (let i = 1; i <= 16; i++) { frequency[i] = 0; }
      this.savedResults.forEach(result => {
        frequency[result.blueBall]++;
      });
      return Object.fromEntries(
        Object.entries(frequency).filter(([_, freq]) => freq > 0)
         // Keep unsorted for chart display by number
      );
    },
    sortedRedFrequency() {
      // Sort by number for consistent chart display
      return Object.fromEntries(
        Object.entries(this.redBallFrequency).sort(([a], [b]) => parseInt(a) - parseInt(b))
      );
    },
    sortedBlueFrequency() {
      // Sort by number for consistent chart display
      return Object.fromEntries(
        Object.entries(this.blueBallFrequency).sort(([a], [b]) => parseInt(a) - parseInt(b))
      );
    },
     maxRedFrequency() {
      const allRedFrequencies = Object.values(this.redBallFrequency);
      return allRedFrequencies.length > 0 ? Math.max(...allRedFrequencies) : 1;
    },
    maxBlueFrequency() {
      const allBlueFrequencies = Object.values(this.blueBallFrequency);
      return allBlueFrequencies.length > 0 ? Math.max(...allBlueFrequencies) : 1;
    },
    maxFrequency() {
      return Math.max(this.maxRedFrequency, this.maxBlueFrequency);
    }
  },
  methods: {
    // ... (keep existing methods: generateNumbers, saveNumbers, deleteResult, formatDate, loadSavedResults) ...
     generateNumbers() {
      this.redBalls = [];
      this.blueBalls = [];
      this.hasGeneratedNumbers = false;
      const redBallsSet = new Set();
      while (redBallsSet.size < 6) {
        redBallsSet.add(Math.floor(Math.random() * 33) + 1);
      }
      this.redBalls = [...redBallsSet].sort((a, b) => a - b);
      this.blueBalls = [Math.floor(Math.random() * 16) + 1];
      this.hasGeneratedNumbers = true;
    },
    saveNumbers() {
      if (!this.hasGeneratedNumbers) return;
      const result = {
        redBalls: [...this.redBalls],
        blueBall: this.blueBalls[0],
        timestamp: new Date()
      };
      this.savedResults.unshift(result);
      localStorage.setItem('doubleColorBallHistory', JSON.stringify(this.savedResults));
    },
    deleteResult(index) {
      this.savedResults.splice(index, 1);
      localStorage.setItem('doubleColorBallHistory', JSON.stringify(this.savedResults));
    },
    formatDate(dateString) {
      const date = new Date(dateString);
      return new Intl.DateTimeFormat('zh-CN', {
        year: 'numeric', month: '2-digit', day: '2-digit',
        hour: '2-digit', minute: '2-digit'
      }).format(date);
    },
    loadSavedResults() {
      const saved = localStorage.getItem('doubleColorBallHistory');
      if (saved) {
        try {
          this.savedResults = JSON.parse(saved);
        } catch (e) {
          console.error('Error loading saved results', e);
          localStorage.removeItem('doubleColorBallHistory');
        }
      }
    }
  },
  mounted() {
    this.loadSavedResults();
    // Only generate if no numbers loaded/saved initially? Or always generate? Let's keep always generate.
    this.generateNumbers(); 
  }
}
</script>

<style scoped>
.chart-container {
  display: flex;
  align-items: flex-end; /* Align bars at the bottom */
  gap: 8px; /* Space between bars */
  height: 150px; /* Max chart height + label space */
  border-bottom: 1px solid #eee;
  padding: 10px 5px 5px 5px;
  overflow-x: auto; /* Allow horizontal scrolling if needed */
  overflow-y: hidden;
  background-color: #f8f9fa; /* Light background for contrast */
  border-radius: 4px;
}

.bar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  min-width: 25px; /* Ensure labels don't wrap too easily */
}

.bar {
  display: block;
  width: 20px; /* Width of the bars */
  margin-top: 4px; /* Space between top label and bar */
  margin-bottom: 4px; /* Space between bar and bottom label */
  border-radius: 3px 3px 0 0; /* Slightly rounded top corners */
  transition: height 0.3s ease-in-out; /* Animate height changes */
}

.red-bar {
  background-color: #dc3545; /* Bootstrap danger red */
}

.blue-bar {
  background-color: #0d6efd; /* Bootstrap primary blue */
}

.bar-label {
  font-size: 0.75em; /* Smaller font for labels */
  color: #6c757d; /* Muted text color */
  line-height: 1;
}

.number-label {
  font-weight: bold;
  color: #495057;
}

/* Add some general styling if not already present */
.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 20px; /* Reduced margin */
  padding-bottom: 10px; /* Reduced padding */
  border-bottom: 1px solid #eee;
}

.title-decoration {
  color: #333;
  font-weight: bold;
}

.lottery-card, .stats-container {
  background-color: #fff;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  margin-bottom: 20px; /* Ensure space below containers */
}

.ball-container {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 20px;
}

.lottery-ball {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  display: inline-flex;
  justify-content: center;
  align-items: center;
  font-size: 1.2em;
  font-weight: bold;
  color: white;
  box-shadow: inset 0 -3px 5px rgba(0,0,0,0.2), 0 2px 3px rgba(0,0,0,0.2);
}

.red-ball { background-color: #dc3545; }
.blue-ball { background-color: #0d6efd; }

.history-ball {
  width: 30px;
  height: 30px;
  font-size: 0.9em;
  margin-bottom: 2px; /* Align better in table cell */
}

.btn-generate {
  background-color: #198754; /* Bootstrap success green */
  color: white;
}
.btn-generate:hover {
  background-color: #157347;
}

.btn-save {
  background-color: #ffc107; /* Bootstrap warning yellow */
  color: #333;
}
.btn-save:hover {
  background-color: #e0a800;
}
.btn-save:disabled {
  background-color: #e9ecef;
  border-color: #ced4da;
}

.history-table {
  margin-top: 15px;
}

.footer {
  text-align: center;
  margin-top: 40px;
  padding-top: 20px;
  border-top: 1px solid #eee;
  color: #6c757d;
  font-size: 0.9em;
}

/* Animation for newly generated balls */
@keyframes pop-in {
  0% { transform: scale(0.5); opacity: 0; }
  70% { transform: scale(1.1); opacity: 1; }
  100% { transform: scale(1); }
}

.animated-ball {
  animation: pop-in 0.5s ease-out forwards;
}

/* Ensure table responsiveness doesn't hide content unnecessarily */
.table-responsive {
  overflow-x: auto; /* Only add scrollbar if truly needed */
}
</style>
