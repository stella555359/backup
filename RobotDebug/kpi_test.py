import paramiko
import tempfile
import os


def execute_and_copy_html(source_server_ip="10.57.159.149", source_username="ute", source_password="iW_K#8.ute%A10h0m0ra", 
                          script_path="/home/ute/kpi-anomaly-detector/scripts/run_detector.py", test_data_dir="Stella", 
                          report_dir="/home/ute/kpi_test_reports/Stella", dest_server_ip="10.57.169.251", 
                          dest_username="hz4sg6", dest_password="Ut3pa5s#ff97", dest_dir=None, local_file_path=None):
    """
    Execute a Python script on a remote server and copy the generated HTML file to another server.

    :param source_server_ip: Source server IP address
    :param source_username: Source server username
    :param source_password: Source server password
    :param script_path: Path to the script on the source server
    :param test_data_dir: Test data directory on the source server
    :param report_dir: Report directory on the source server
    :param dest_server_ip: Destination server IP address
    :param dest_username: Destination server username
    :param dest_password: Destination server password
    :param dest_dir: Destination directory on the destination server
    :param file: Path to the file to upload
    :return: None
    """
    try:
        # Step 1: Upload test data to the source server
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(source_server_ip, username=source_username, password=source_password)

        sftp = ssh.open_sftp()
        remote_test_data_dir = f"kpi_test_data/{test_data_dir}"

        # Ensure the remote test data directory exists
        try:
            print(f"Checking if remote test data directory exists: {remote_test_data_dir}")
            sftp.stat(remote_test_data_dir)
        except FileNotFoundError:
            # Create the directory recursively if it does not exist
            dirs = remote_test_data_dir.split('/')
            current_path = ''
            for directory in dirs:
                if directory:  # Skip empty parts
                    current_path = f"{current_path}/{directory}" if current_path else directory
                    try:
                        sftp.stat(current_path)
                    except FileNotFoundError:
                        sftp.mkdir(current_path)

        # Upload the specified file to the remote test data directory
        remote_file_path = f"{remote_test_data_dir}/{os.path.basename(local_file_path)}"
        print(f"Uploading {local_file_path} to {remote_file_path}")
        sftp.put(local_file_path, remote_file_path)

        sftp.close()

        # Step 2: Execute the script on the source server
        script_args = f"{remote_file_path} --reports-dir {report_dir}"
        command = f"python {script_path} {script_args}"
        print(f"Executing command: {command}")

        stdin, stdout, stderr = ssh.exec_command(command)
        output = stdout.read().decode()
        error = stderr.read().decode()
        ssh.close()

        if error:
            print(f"Error during script execution: {error}")
            return

        print("Script executed successfully. Output:")
        print(output)

        # Step 3: Extract the HTML file path from the output
        html_file_path = None
        for line in output.splitlines():
            if "HTML report saved to:" in line:
                html_file_path = line.split("HTML report saved to:")[-1].strip()
                break

        if not html_file_path:
            print("Failed to extract HTML file path from the output.")
            return

        print(f"Extracted HTML file path: {html_file_path}")

        # Step 4: Copy the HTML file to the destination server
        source_ssh = paramiko.SSHClient()
        source_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        source_ssh.connect(source_server_ip, username=source_username, password=source_password)

        sftp_source = source_ssh.open_sftp()
        local_temp_file = tempfile.NamedTemporaryFile(delete=False).name  # Generate a temporary file
        # Download the HTML file to the local machine
        sftp_source.get(html_file_path, local_temp_file)
        sftp_source.close()
        source_ssh.close()

        dest_ssh = paramiko.SSHClient()
        dest_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        dest_ssh.connect(dest_server_ip, username=dest_username, password=dest_password)

        sftp_dest = dest_ssh.open_sftp()

        # Ensure the destination directory exists
        try:
            sftp_dest.stat(dest_dir)
        except FileNotFoundError:
            sftp_dest.mkdir(dest_dir)

        # Upload the HTML file to the destination directory
        dest_file_path = f"{dest_dir}/{html_file_path.split('/')[-1]}"
        sftp_dest.put(local_temp_file, dest_file_path)
        sftp_dest.close()
        dest_ssh.close()

        print(f"HTML file successfully copied to {dest_server_ip}:{dest_file_path}")

    except Exception as e:
        print(f"Error occurred: {e}")


# Example usage
if __name__ == "__main__":
    source_server_ip = "10.57.159.149"
    source_username = "ute"
    source_password = "iW_K#8.ute%A10h0m0ra"  # Replace with the actual password
    script_path = "/home/ute/kpi-anomaly-detector/scripts/run_detector.py"
    test_data_dir = "Stella"
    report_dir = "/home/ute/kpi_test_reports/Stella"

    dest_server_ip = "10.57.169.251"
    dest_username = "hz4sg6"
    dest_password = "Ut3pa5s#ff97"  # Replace with the actual password
    dest_dir = "/home/hz4sg6/shared/01_E2E_Rep/T080/5605005_E2E_Rep_005_Concurrent PS-BWP swtich and scell addtion/SBTS26R2_ENB_9999_260126_000007/"

    local_file_path = "C:\\TA\\RobotDebug\\7UEs_SFTPDL\\0204.3_26R2.0126.7_T076.SCF.T080_7UEs_SFTPDL_1csv8run.xlsx"  # Replace with the actual file path

    execute_and_copy_html(source_server_ip, source_username, source_password, script_path, test_data_dir, report_dir, 
                          dest_server_ip, dest_username, dest_password, dest_dir, local_file_path)