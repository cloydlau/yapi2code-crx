<%
  params && (params = JSON.parse(params).properties)
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
      <el-form ref="listFilterFormRef" :model="list.filter" inline>
        <% Object.keys(params).map(v => { %>
          <el-form-item prop="<%- v %>">
            <el-input v-model.trim="list.filter.<%- v %>" placeholder="<%- params[v].description %>" clearable>
              <i slot="prefix" class="el-input__icon el-icon-search"/>
            </el-input>
          </el-form-item>
        <% }) %>
        <el-form-item prop="status">
          <KiSelect :index.sync="list.filter.status" :options="options.status" placeholder="状态"/>
        </el-form-item>
        <el-button @click="reset">重置</el-button>
      </el-form>
    <% } %>

    <div class="flex justify-between my-20px">
      <span>
        <el-button
          v-if="pageBtnList.includes('新增')"
          type="primary"
          icon="el-icon-circle-plus-outline"
          @click="c"
        >
          新增
        </el-button>
      </span>
      <el-pagination
        v-bind="elPaginationProps"
        :total="list.total"
        :currentPage.sync="list.filter.pageNo"
      />
    </div>

    <el-table
      stripe
      v-loading="list.loading"
      :data="list.data"
      border
      fit
      highlight-current-row
    >
      <% Object.keys(res).map(v => { %>
      <el-table-column label="<%- res[v].description||res[v].default %>" prop="<%- v %>"/><% }); %>
      <el-table-column label="状态" align="center">
        <template slot-scope="{row:{id,status}}">
          <KiPopSwitch
            v-bind="popSwitchProps(status)"
            @change="updateStatus({id,status:status^1})"
          />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" min-width="204px">
        <template slot-scope="{row:{id,status}}">
          <KiPopButton
            v-if="pageBtnList.includes('查看')"
            size="mini"
            icon="el-icon-search"
            @click="r({id})"
          >
            查看
          </KiPopButton>
          <KiPopButton
            v-if="pageBtnList.includes('编辑')"
            size="mini"
            type="primary"
            icon="el-icon-edit"
            @click="u({id})"
          >
            编辑
          </KiPopButton>
          <KiPopButton
            v-if="pageBtnList.includes('删除')"
            :elPopconfirmProps="{title:'确认删除吗？'}"
            size="mini"
            type="danger"
            icon="el-icon-delete"
            @click="d({id})"
          >
            删除
          </KiPopButton>
        </template>
      </el-table-column>
    </el-table>

    <KiFormDialog
      :show.sync="row.show"
      :title="dialogTitle"
      v-model="row.data"
      :submit="submit"
      :readonly="row.status==='r'"
      ref="rowDataFormRef"
    >
      <template #el-form>
        <% Object.keys(res).map(v => { %>
          <el-form-item label="<%- res[v].description %>" prop="<%- v %>" verify>
            <el-input v-model.trim="row.data.<%- v %>" clearable maxlength="30" show-word-limit/>
          </el-form-item><% })
        %>
      </template>
    </KiFormDialog>
  </div>
</template>

<script>
import pageMixin from '@/utils/pageMixin'
import useMyAdmate from '@/utils/useMyAdmate'

export default {
  mixins: [pageMixin],
  components: {},
  setup: () => useMyAdmate({
    urlPrefix: '<%= name %>',
  }),
  created () {

  },
  data () {
    return {

    }
  },
  methods: {

  },
}
</script>

<style lang="scss" scoped>

</style>
