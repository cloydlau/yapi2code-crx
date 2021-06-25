import { ViteSSG } from 'vite-ssg'
import generatedRoutes from 'virtual:generated-pages'
import { setupLayouts } from 'virtual:generated-layouts'
import App from './App.vue'
import 'virtual:windi.css'
import 'virtual:windi-devtools'
import './styles/main.scss'
import { createWebHashHistory } from 'vue-router'

const routes = setupLayouts(generatedRoutes)

//import 'element-plus/lib/theme-chalk/index.css'
//import ElementPlus from 'element-plus'

//import vuetify from './plugins/vuetify'

// https://github.com/antfu/vite-ssg
export const createApp = ViteSSG(
  App,
  {
    routes,
    history: createWebHashHistory()
  },
  (ctx) => {

    //ctx.app.use(vuetify)
    //ctx.app.use(ElementPlus)

    // install all modules under `modules/`
    Object.values(import.meta.globEager('./modules/*.ts')).map(i => i.install?.(ctx))
  },
)
