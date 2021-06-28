<%
  params && (params = JSON.parse(params).properties)
  const isPartial = importMode === 'partially'
  // 结构
  // `{"properties":{"data":{"properties":{}}}}`
  let data = JSON.parse(res).properties.data
  if (data) {
    if (data.items && data.items.properties) {
      //不分页
      res = data.items.properties
    } else if (data.properties && data.properties.records) {
      //分页
      res = data.properties.records.items.properties
    } else if (data.properties && data.properties.list) {
      //兼容老接口
      res = data.properties.list.items.properties
    }
  }
%>
<template>
  <div class="p-20px">
    <% if (params) { %>
      <el-form ref="listFilter" :model="list__.filter" inline>
        <% Object.keys(params).map(v => { %>
          <el-form-item prop="<%- v %>">
            <el-input v-model.trim="list__.filter.<%- v %>" placeholder="<%- params[v].description %>" clearable>
              <i slot="prefix" class="el-input__icon el-icon-search"/>
            </el-input>
          </el-form-item>
        <% }) %>
        <el-form-item prop="status">
          <Selector v-model="list__.filter.status" :options="['停用', '启用']" placeholder="状态"/>
        </el-form-item>
        <el-button @click="()=>{$refs.listFilter.resetFields()}">重置</el-button>
      </el-form>
    <% } %>

    <div class="flex justify-between my-20px">
      <span>
        <AuthButton <%- isPartial ? ':show="showAuthButton"' : '' %> @click="c__" name="新增"/>
      </span>
      <Pagination :total="list__.total" :currentPage.sync="list__.filter.pageNo"/>
    </div>

    <el-table
      stripe
      v-loading="list__.loading"
      :data="list__.data"
      border
      fit
      highlight-current-row
    >
      <el-table-column align="center" type="index"/><% Object.keys(res).map(v => { %>
      <el-table-column label="<%- res[v].description||res[v].default %>" prop="<%- v %>"/><% }); %>
      <el-table-column label="状态" align="center">
        <template slot-scope="{row:{status}}">
          <Tag :value="status" options="status"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center">
        <template slot-scope="{row:{id,status}}">
          <AuthButton <%- isPartial ? ':show="showAuthButton"' : '' %> @click="r__({id})" name="查看"/>
          <AuthButton <%- isPartial ? ':show="showAuthButton"' : '' %> @click="u__({id})" name="编辑"/>
          <AuthButton <%- isPartial ? ':show="showAuthButton"' : '' %> @click="updateStatus__({id,status:status^1})" :name="['启用', '停用'][status]"/>
          <AuthButton <%- isPartial ? ':show="showAuthButton"' : '' %> @click="d__({id})" name="删除"/>
        </template>
      </el-table-column>
    </el-table>

    <FormDialog
      :show.sync="row__.show"
      :title="row__.status | $dialogTitle"
      v-model="row__.data"
      :retrieve="retrieve__"
      :submit="submit__"
      :readonly="row__.status==='r'"
    >
      <template #el-form>
        <% Object.keys(res).map(v => { %>
          <el-form-item label="<%- res[v].description %>" prop="<%- v %>" verify>
            <el-input v-model="row__.data.<%- v %>" clearable maxlength="30" show-word-limit/>
          </el-form-item><% })
        %>
      </template>
    </FormDialog>
  </div>
</template>

<script>
import { apiGenerator, mixins, <%- isPartial ? '$filters, $axiosShortcut, showAuthButton' : '' %> } from '@/utils/<%- isPartial ? 'admate' : 'init' %>'
import 'kikimore/dist/style.css'
import { FormDialog, AuthButton, Selector, Pagination, FormItemTip, Tag, Swal } from 'kikimore'
const { success, info, warning, error, confirm } = Swal

export default {
  mixins: [mixins],
<% if (isPartial) { %>
  components: { FormDialog, AuthButton, Selector, Pagination, FormItemTip, Tag },
  filters: {
      ...$filters
  },
<% } %>
  data () {
    return {
      api__: apiGenerator("<%= name %>"),
      <%- isPartial ? 'showAuthButton,' : '' %>
    }
  },
  methods: {
    <%- isPartial ? '...$axiosShortcut,' : '' %>
  }
}
</script>

<style lang="scss" scoped>

</style>
