import Vue from 'vue'
import App from './App.vue'
import router from './router'
require(`@/plugins/element-ui`)
require(`@/plugins/clipboard`)
require(`@/plugins/base64`)
require(`@/plugins/axios`)
require(`@/plugins/device`)


import './assets/css/base.css'
import 'element-ui/lib/theme-chalk/index.css'
import './assets/css/light.min.css'
import './assets/css/dark.min.css'

Vue.config.productionTip = false

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
