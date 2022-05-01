# game

a funny game

## 配置表数据结构

### image_alias.json

- key: 图片别名定义
- path: 资源路径
- srcSize: 分割大小

### animation.json

- pic: 图片别名
- enum: 定义枚举名
- animations: 动画

### tile.json

- id: 瓦片唯一ID
- pic: 图片别名
- pos: 图集中的位置
- width: 瓦片的宽度，默认为1
- height: 瓦片的高度，默认为1

### map.json

- defaultTile: 默认的瓦片
- map: 支持的地图