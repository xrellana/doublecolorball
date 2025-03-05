<template>
  <div class="app-container">
    <header class="page-header">
      <h1 class="title-decoration">双色球生成器</h1>
      <p class="text-muted">Generate random Double Color Ball lottery numbers</p>
    </header>

    <main>
      <div class="row">
        <div class="col-lg-8 mx-auto">
          <div class="lottery-card">
            <h2 class="text-center mb-4">今日幸运号码 / Lucky Numbers</h2>
            
            <div class="ball-container">
              <div v-for="(ball, index) in redBalls" :key="`red-${index}`" 
                   class="lottery-ball red-ball animated-ball">
                {{ ball }}
              </div>
              <div v-for="(ball, index) in blueBalls" :key="`blue-${index}`"
                   class="lottery-ball blue-ball animated-ball">
                {{ ball }}
              </div>
            </div>
            
            <div class="d-flex justify-content-center gap-3 mt-4">
              <button @click="generateNumbers" class="btn btn-generate">
                <i class="bi bi-shuffle me-2"></i>生成号码 / Generate
              </button>
              <button @click="saveNumbers" class="btn btn-save" :disabled="!hasGeneratedNumbers">
                <i class="bi bi-bookmark-plus me-2"></i>保存 / Save
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="row mt-5">
        <div class="col-lg-6">
          <div class="stats-container">
            <h3 class="mb-4">生成历史 / History</h3>
            <div class="table-responsive">
              <table class="table history-table" v-if="savedResults.length > 0">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>红球 / Red Balls</th>
                    <th>蓝球 / Blue Ball</th>
                    <th>时间 / Time</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(result, index) in savedResults" :key="index">
                    <td>{{ index + 1 }}</td>
                    <td>
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
                    <td>{{ formatDate(result.timestamp) }}</td>
                    <td>
                      <button @click="deleteResult(index)" class="btn btn-sm btn-outline-danger">
                        <i class="bi bi-trash"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
              <p v-else class="text-muted text-center">No saved results yet</p>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="stats-container">
            <h3 class="mb-4">号码统计 / Statistics</h3>
            <div v-if="savedResults.length > 0">
              <h5>红球频率 / Red Ball Frequency</h5>
              <div class="progress mb-3" style="height: 25px;" v-for="(freq, number) in redBallFrequency" :key="number">
                <div class="progress-bar bg-danger" 
                     :style="{ width: `${(freq / maxFrequency) * 100}%` }">
                  {{ number }}: {{ freq }} 次
                </div>
              </div>

              <h5 class="mt-4">蓝球频率 / Blue Ball Frequency</h5>
              <div class="progress mb-3" style="height: 25px;" v-for="(freq, number) in blueBallFrequency" :key="number">
                <div class="progress-bar bg-primary" 
                     :style="{ width: `${(freq / maxFrequency) * 100}%` }">
                  {{ number }}: {{ freq }} 次
                </div>
              </div>
            </div>
            <p v-else class="text-muted text-center">No statistics available yet</p>
          </div>
        </div>
      </div>
    </main>

    <footer class="footer">
      <p>© {{ currentYear }} 双色球模拟生成器 - Double Color Ball Generator</p>
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
    
    maxFrequency() {
      // Get the max frequency across all balls for scaling the progress bars
      const redMax = Object.values(this.redBallFrequency)[0] || 0;
      const blueMax = Object.values(this.blueBallFrequency)[0] || 0;
      return Math.max(redMax, blueMax, 1); // At least 1 to avoid division by zero
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
  }
}
</script>