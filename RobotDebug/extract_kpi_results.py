import pandas as pd

def read_excel_as_str(file_path):
    """
    读取Excel文件，将每一列的值以字符串形式读取，并打印每一列的值。

    :param file_path: Excel文件路径
    """
    try:
        # 读取Excel文件
        df = pd.read_excel(file_path, dtype=str)

        # 遍历每一列并打印值
        for column in df.columns:
            print(f"列名: {column}")
            print(df[column].tolist())
    except Exception as e:
        print(f"读取Excel文件时发生错误: {e}")

if __name__ == "__main__":    # 替换为你的Excel文件路径
    excel_file_path = "Auto_test_input.xlsx"
    read_excel_as_str(excel_file_path)