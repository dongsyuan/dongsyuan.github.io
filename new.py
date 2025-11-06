import os
import re
import tempfile
import subprocess
import time
from datetime import datetime
import sys

def main():
    # 目标文件夹路径
    target_dir = r"F:\myblog\source\_posts"
    
    # 检查并创建目标文件夹
    if not os.path.exists(target_dir):
        try:
            os.makedirs(target_dir)
            print(f"已创建目录: {target_dir}")
        except OSError as e:
            print(f"错误：无法创建文件夹 {target_dir}")
            print(f"错误信息: {e}")
            input("按任意键退出...")
            return
    
    # 获取当前时间
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 创建临时文件
    temp_file = os.path.join(target_dir, "new_post.md")
    
    # 写入YAML格式内容
    with open(temp_file, 'w', encoding='utf-8') as f:
        f.write("---\n")
        f.write("title: \n")
        f.write(f"time: {current_time}\n")
        f.write("---\n")
        f.write("\n")
    
    print("正在打开记事本，请编辑文章内容...")
    print("注意：编辑完成后请保存并关闭记事本")
    
    # 打开记事本
    try:
        subprocess.run(["notepad.exe", temp_file], check=True)
    except subprocess.CalledProcessError:
        print("错误：无法打开记事本")
        input("按任意键退出...")
        return
    
    # 读取标题
    title = "未命名文档"
    try:
        with open(temp_file, 'r', encoding='utf-8') as f:
            for line in f:
                if line.lower().startswith("title:"):
                    title = line[6:].strip()
                    break
    except Exception as e:
        print(f"错误：读取文件失败 - {e}")
        input("按任意键退出...")
        return
    
    # 清理文件名中的非法字符
    safe_title = re.sub(r'[\\/:*?"<>|]', '', title)
    if not safe_title:
        safe_title = "未命名文档"
    
    # 处理重名文件
    base_name = safe_title
    counter = 1
    final_name = f"{base_name}.md"
    final_path = os.path.join(target_dir, final_name)
    
    while os.path.exists(final_path):
        final_name = f"{base_name}_{counter}.md"
        final_path = os.path.join(target_dir, final_name)
        counter += 1
    
    # 重命名文件（如果不是默认名称）
    if final_name != "new_post.md":
        try:
            os.rename(temp_file, final_path)
            print(f"文件已创建: {final_name}")
        except OSError as e:
            print(f"错误：重命名文件失败 - {e}")
            input("按任意键退出...")
            return
    else:
        print(f"文件已创建但未重命名: {final_name}")
    
    print("\n操作完成！")
    input("按任意键退出...")

if __name__ == "__main__":
    main()