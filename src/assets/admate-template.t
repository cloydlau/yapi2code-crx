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
          <Selector v-model="list__.filter.status" :options="options.status" placeholder="状态"/>
        </el-form-item>
        <el-button @click="()=>{$refs.listFilter.resetFields()}">重置</el-button>
      </el-form>
    <% } %>

    <div class="flex justify-between my-20px">
      <span>
        <el-button
          v-if="hasPermission('新增')"
          icon="el-icon-circle-plus-outline"
          @click="c__"
        >
          新增
        </el-button>
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
          <PopSwitch
            v-bind.sync="popSwitchProps(status)"
            @click="updateStatus__({id,status:status^1})"
          />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center">
        <template slot-scope="{row:{id,status}}">
          <PopButton
            v-if="hasPermission('查看')"
            :elTooltipProps="{content:'查看'}"
            icon="el-icon-search"
            @click="r__({id})"
          />
          <PopButton
            v-if="hasPermission('编辑')"
            :elTooltipProps="{content:'编辑'}"
            icon="el-icon-edit"
            type="primary"
            @click="u__({id})"
          />
          <PopButton
            v-if="hasPermission('删除')"
            :elTooltipProps="{content:'删除'}"
            :elPopconfirmProps="{title:'确认删除吗？'}"
            icon=el-icon-delete
            type="danger"
            @click="d__({id})"
          />
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
import { apiGenerator, mixins, <%- isPartial ? '$filters, $axiosShortcut' : '' %> } from '@/utils/<%- isPartial ? 'admate' : 'init' %>'
import 'kikimore/dist/style.css'
import { FormDialog, AuthButton, Selector, Pagination, FormItemTip, Swal } from 'kikimore'
const { success, info, warning, error, confirm } = Swal
import { hasPermission } from '@/utils/has-permission'

export default {
  mixins: [mixins],
<% if (isPartial) { %>
  components: { FormDialog, AuthButton, Selector, Pagination, FormItemTip },
  filters: {
    ...$filters
  },
<% } %>
  data () {
    return {
      api__: apiGenerator("<%= name %>"),
      popSwitchProps (status) {
        return {
          value: status,
          activeValue: 1,
          inactiveValue: 0,
          elTooltipProps: {content:this.options.status[status]},
          ...this.hasPermission(this.options.status[status]) ?
            {
              elPopconfirmProps: { title: `确认${this.options.status.reverse()[status]}吗` },
            } :
            {
              elPopoverProps: { title:'暂无权限' },
            }
        }
      },
      options: {
        status: ['停用', '启用'],
      },
    }
  },
  methods: {
    <%- isPartial ? '...$axiosShortcut,' : '' %>
    hasPermission,
  }
}
</script>

<style lang="scss" scoped>

</style>
