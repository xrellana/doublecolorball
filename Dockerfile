# 使用 Node 镜像
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制所有源代码
COPY . .

# 构建应用
RUN npm run build

# 暴露 3200 端口
EXPOSE 3100

# 启动 Vite 预览服务
CMD ["npm", "run", "preview", "--", "--port", "3200", "--host"]