<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%
    // 세션 확인
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login");
        return;
    }
%>

<%
    String relativePath = request.getParameter("path");
    if (relativePath == null) relativePath = "";

    // 보안 검증
    if (relativePath.contains("..") || relativePath.contains("\\")) {
        out.println("<h3>잘못된 경로입니다.</h3>");
        return;
    }
    
    String baseDir = "/files";
    String realPath = application.getRealPath(baseDir + "/" + relativePath);
    File currentDir = new File(realPath);
    if (!currentDir.exists() || !currentDir.isDirectory()) {
        out.println("<h3>잘못된 경로입니다.</h3>");
        return;
    }
%>

<% 
    // 페이지 타이틀 설정
    pageContext.setAttribute("pageTitle", "파일 업로드");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>파일 업로드 - <%= relativePath.isEmpty() ? "/" : ("/" + relativePath) %></title>
    <style>
        /* 모든 스타일을 인라인으로 포함 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        
        .container {
            width: 100%;
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        .upload-main {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 30px;
        }
        
        .back-link {
            display: inline-flex;
            align-items: center;
            color: #6c757d;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 20px;
            padding: 8px 16px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            transition: all 0.3s ease;
        }
        
        .back-link:hover {
            color: #007bff;
            text-decoration: none;
            background-color: #f8f9fa;
        }
        
        .breadcrumb {
            background: #f8f9fa;
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 30px;
            font-size: 14px;
            border: 1px solid #dee2e6;
        }
        
        .breadcrumb a {
            color: #495057;
            text-decoration: none;
        }
        
        .breadcrumb a:hover {
            color: #007bff;
            text-decoration: underline;
        }
        
        h2 {
            color: #495057;
            margin-bottom: 10px;
        }
        
        .text-muted {
            color: #6c757d;
            margin-bottom: 20px;
        }
        
        .upload-info {
            background: #e7f3ff;
            border: 1px solid #b3d9ff;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 30px;
        }
        
        .upload-info h6 {
            color: #0056b3;
            margin-bottom: 10px;
            font-size: 16px;
        }
        
        .upload-info ul {
            margin: 0;
            padding-left: 20px;
        }
        
        .upload-info li {
            color: #495057;
            font-size: 14px;
            margin-bottom: 5px;
        }
        
        .upload-form {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 8px;
            border: 2px dashed #dee2e6;
            text-align: center;
            margin-bottom: 30px;
            transition: all 0.3s ease;
        }
        
        .upload-form:hover {
            border-color: #007bff;
            background: #e3f2fd;
        }
        
        .upload-form.dragover {
            border-color: #007bff;
            background: #e3f2fd;
            transform: scale(1.02);
        }
        
        .file-input {
            margin: 20px 0;
        }
        
        .file-input input[type="file"] {
            display: none;
        }
        
        .file-input label {
            display: inline-block;
            padding: 12px 24px;
            background: #007bff;
            color: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: background 0.3s ease;
        }
        
        .file-input label:hover {
            background: #0056b3;
        }
        
        .selected-files {
            margin-top: 20px;
            text-align: left;
        }
        
        .selected-files h5 {
            margin-bottom: 15px;
            color: #495057;
        }
        
        .file-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px;
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        
        .file-info {
            display: flex;
            align-items: center;
        }
        
        .file-icon {
            margin-right: 10px;
            font-size: 20px;
        }
        
        .file-details {
            flex: 1;
        }
        
        .file-name {
            font-weight: 500;
            color: #495057;
        }
        
        .file-size {
            font-size: 12px;
            color: #6c757d;
        }
        
        .remove-file {
            color: #dc3545;
            cursor: pointer;
            padding: 5px;
            border-radius: 4px;
            transition: background 0.3s ease;
        }
        
        .remove-file:hover {
            background: #f8d7da;
        }
        
        .upload-controls {
            margin-top: 30px;
            text-align: center;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            font-size: 16px;
            font-weight: 500;
            text-align: center;
            text-decoration: none;
            border: 1px solid transparent;
            border-radius: 6px;
            cursor: pointer;
            margin: 0 5px;
            transition: all 0.3s ease;
        }
        
        .btn-primary {
            background-color: #007bff;
            border-color: #007bff;
            color: white;
        }
        
        .btn-primary:hover:not(:disabled) {
            background-color: #0056b3;
            border-color: #0056b3;
        }
        
        .btn-primary:disabled {
            background-color: #6c757d;
            border-color: #6c757d;
            cursor: not-allowed;
            opacity: 0.6;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #545b62;
            border-color: #545b62;
        }
        
        .progress-container {
            display: none;
            margin-top: 20px;
        }
        
        .progress {
            height: 25px;
            background-color: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
            border: 1px solid #dee2e6;
        }
        
        .progress-bar {
            height: 100%;
            background-color: #007bff;
            transition: width 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 500;
            font-size: 14px;
        }
        
        .upload-status {
            display: none;
            margin-top: 20px;
            padding: 15px;
            border-radius: 6px;
        }
        
        .upload-status.success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
        
        .upload-status.error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }
        
        .text-center {
            text-align: center;
        }
        
        .mt-2 {
            margin-top: 0.5rem;
        }
    </style>
</head>
<body>
    <!-- Header Include -->
    <%@ include file="includes/header.jsp" %>

    <div class="container">
        <div class="upload-main">
            <!-- 뒤로가기 링크 -->
            <a href="downlist.jsp?path=<%= relativePath %>" class="back-link">
                ⬅️ 파일 목록으로 돌아가기
            </a>

            <!-- 현재 경로 표시 -->
            <div class="breadcrumb">
                <strong>📤 업로드 위치:</strong> 
                <a href="downlist.jsp">/</a><%
                if (!relativePath.isEmpty()) {
                    String[] parts = relativePath.split("/");
                    String currentPath = "";
                    for (int i = 0; i < parts.length; i++) {
                        if (!parts[i].isEmpty()) {
                            currentPath += parts[i];
                            out.print("<a href=\"downlist.jsp?path=" + currentPath + "\">" + parts[i] + "</a>");
                            if (i < parts.length - 1) out.print("/");
                            currentPath += "/";
                        }
                    }
                }
                %>
            </div>

            <h2>📤 파일 업로드</h2>
            <p class="text-muted">업로드할 파일을 선택하거나 드래그하여 놓으세요.</p>

            <!-- 업로드 정보 -->
            <div class="upload-info">
                <h6>📋 업로드 안내사항</h6>
                <ul>
                    <li>최대 파일 크기: <strong>10MB</strong></li>
                    <li>허용되지 않는 파일: .exe, .jsp, .php, .bat, .cmd, .scr</li>
                    <li>동일한 이름의 파일이 있으면 자동으로 번호가 추가됩니다</li>
                    <li>여러 파일을 동시에 선택할 수 있습니다</li>
                </ul>
            </div>

            <!-- 업로드 폼 -->
            <form id="uploadForm">
                <input type="hidden" name="path" value="<%= relativePath %>">
                
                <div class="upload-form" id="uploadArea">
                    <div style="font-size: 48px; color: #007bff; margin-bottom: 20px;">📁</div>
                    <h4>파일을 여기에 드래그하거나</h4>
                    <div class="file-input">
                        <label for="fileInput">
                            파일 선택하기
                        </label>
                        <input type="file" id="fileInput" name="uploadFiles" multiple accept="*/*">
                    </div>
                    <p class="text-muted">여러 파일을 동시에 선택할 수 있습니다</p>
                </div>

                <!-- 선택된 파일 목록 -->
                <div id="selectedFiles" class="selected-files" style="display: none;">
                    <h5>선택된 파일 목록</h5>
                    <div id="fileList"></div>
                </div>

                <!-- 진행률 표시 -->
                <div class="progress-container" id="progressContainer">
                    <div class="progress">
                        <div class="progress-bar" id="progressBar" role="progressbar" style="width: 0%">0%</div>
                    </div>
                    <p class="text-center mt-2" id="progressText">업로드 준비 중...</p>
                </div>

                <!-- 업로드 상태 메시지 -->
                <div id="uploadStatus" class="upload-status"></div>

                <!-- 업로드 버튼 -->
                <div class="upload-controls">
                    <button type="submit" class="btn btn-primary" id="uploadBtn" disabled>
                        📤 업로드 시작
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="clearFiles()">
                        🗑️ 선택 취소
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Footer Include -->
    <%@ include file="includes/footer.jsp" %>

    <script>
        // 전역 변수
        let selectedFiles = [];
        const maxFileSize = 10 * 1024 * 1024; // 10MB
        const forbiddenExtensions = ['.exe', '.jsp', '.php', '.bat', '.cmd', '.scr'];

        // 페이지 로드 완료 후 실행
        window.addEventListener('load', function() {
            console.log('페이지 로드 완료');
            initializeFileUpload();
        });

        function initializeFileUpload() {
            console.log('파일 업로드 초기화 시작');
            
            // 파일 선택 이벤트
            const fileInput = document.getElementById('fileInput');
            if (fileInput) {
                fileInput.addEventListener('change', function(e) {
                    console.log('파일 선택됨:', e.target.files.length, '개');
                    handleFiles(e.target.files);
                });
                console.log('✓ 파일 input 이벤트 등록됨');
            } else {
                console.error('❌ fileInput 요소를 찾을 수 없습니다!');
                return;
            }

            // 드래그 앤 드롭 이벤트
            const uploadArea = document.getElementById('uploadArea');
            if (uploadArea) {
                uploadArea.addEventListener('dragover', function(e) {
                    e.preventDefault();
                    uploadArea.classList.add('dragover');
                });

                uploadArea.addEventListener('dragleave', function(e) {
                    e.preventDefault();
                    uploadArea.classList.remove('dragover');
                });

                uploadArea.addEventListener('drop', function(e) {
                    e.preventDefault();
                    uploadArea.classList.remove('dragover');
                    console.log('파일 드롭됨:', e.dataTransfer.files.length, '개');
                    handleFiles(e.dataTransfer.files);
                });
                console.log('✓ 드래그앤드롭 이벤트 등록됨');
            } else {
                console.error('❌ uploadArea 요소를 찾을 수 없습니다!');
            }

            // 폼 제출 이벤트
            const uploadForm = document.getElementById('uploadForm');
            if (uploadForm) {
                uploadForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    console.log('폼 제출됨, 선택된 파일 수:', selectedFiles.length);
                    handleFormSubmit();
                });
                console.log('✓ 폼 이벤트 등록됨');
            } else {
                console.error('❌ uploadForm 요소를 찾을 수 없습니다!');
            }
            
            console.log('파일 업로드 초기화 완료');
        }

        function handleFiles(files) {
            console.log('=== handleFiles 시작 ===');
            console.log('받은 파일 수:', files.length);
            
            if (!files || files.length === 0) {
                console.log('선택된 파일이 없습니다');
                return;
            }
            
            const fileArray = Array.from(files);
            
            fileArray.forEach((file, index) => {
                console.log('파일 ' + (index + 1) + ': ' + file.name + ' (' + file.size + ' bytes)');
                
                // 파일 크기 검증
                if (file.size > maxFileSize) {
                    console.warn('파일 크기 초과: ' + file.name);
                    showMessage('파일 "' + file.name + '"이 너무 큽니다. (최대 10MB)', 'error');
                    return;
                }

                // 파일 확장자 검증
                const fileName = file.name.toLowerCase();
                const isForbidden = forbiddenExtensions.some(ext => fileName.endsWith(ext));
                if (isForbidden) {
                    console.warn('금지된 확장자: ' + file.name);
                    showMessage('파일 "' + file.name + '"은 보안상 업로드할 수 없습니다.', 'error');
                    return;
                }

                // 중복 파일 검사
                const isDuplicate = selectedFiles.some(f => f.name === file.name && f.size === file.size);
                if (!isDuplicate) {
                    selectedFiles.push(file);
                    console.log('✓ 파일 추가: ' + file.name);
                } else {
                    console.log('중복 파일 무시: ' + file.name);
                }
            });

            console.log('현재 선택된 파일 총 개수:', selectedFiles.length);
            updateFileList();
            updateUploadButton();
            console.log('=== handleFiles 완료 ===');
        }

        function updateFileList() {
            console.log('=== updateFileList 시작 ===');
            
            const fileList = document.getElementById('fileList');
            const selectedFilesDiv = document.getElementById('selectedFiles');

            if (!fileList || !selectedFilesDiv) {
                console.error('❌ 필요한 DOM 요소를 찾을 수 없습니다!');
                return;
            }

            if (selectedFiles.length === 0) {
                selectedFilesDiv.style.display = 'none';
                console.log('파일이 없어서 목록 숨김');
                return;
            }

            selectedFilesDiv.style.display = 'block';
            fileList.innerHTML = '';
            console.log('✓ 파일 목록 컨테이너 표시');

            selectedFiles.forEach(function(file, index) {
                console.log('파일 ' + index + ' UI 생성: ' + file.name);
                
                const fileItem = document.createElement('div');
                fileItem.className = 'file-item';
                
                const fileIcon = getFileIcon(file.name);
                const fileSize = formatFileSize(file.size);
                const escapedFileName = escapeHtml(file.name);

                // EL 충돌을 피하기 위해 문자열 연결 사용
                fileItem.innerHTML = '<div class="file-info">' +
                    '<div class="file-icon">' + fileIcon + '</div>' +
                    '<div class="file-details">' +
                        '<div class="file-name">' + escapedFileName + '</div>' +
                        '<div class="file-size">' + fileSize + '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="remove-file" onclick="removeFile(' + index + ')">' +
                    '🗑️' +
                '</div>';

                fileList.appendChild(fileItem);
            });
            
            console.log('✓ 파일 목록 UI 생성 완료');
            console.log('=== updateFileList 완료 ===');
        }

        function removeFile(index) {
            console.log('파일 제거:', selectedFiles[index] ? selectedFiles[index].name : 'undefined');
            selectedFiles.splice(index, 1);
            updateFileList();
            updateUploadButton();
        }

        function clearFiles() {
            console.log('모든 파일 제거');
            selectedFiles = [];
            const fileInput = document.getElementById('fileInput');
            if (fileInput) {
                fileInput.value = '';
            }
            updateFileList();
            updateUploadButton();
            hideMessage();
            hideProgress();
        }

        function updateUploadButton() {
            const uploadBtn = document.getElementById('uploadBtn');
            if (uploadBtn) {
                uploadBtn.disabled = selectedFiles.length === 0;
                console.log('업로드 버튼:', uploadBtn.disabled ? '비활성화' : '활성화');
            }
        }

        function getFileIcon(filename) {
            const ext = filename.toLowerCase().split('.').pop();
            
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg'].includes(ext)) return '🖼️';
            if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'].includes(ext)) return '🎬';
            if (['mp3', 'wav', 'flac', 'aac', 'ogg'].includes(ext)) return '🎵';
            if (ext === 'pdf') return '📋';
            if (['doc', 'docx'].includes(ext)) return '📝';
            if (['xls', 'xlsx'].includes(ext)) return '📊';
            if (['zip', 'rar', '7z', 'tar', 'gz'].includes(ext)) return '📦';
            if (['txt', 'log'].includes(ext)) return '📃';
            
            return '📄';
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 B';
            
            const units = ['B', 'KB', 'MB', 'GB'];
            const k = 1024;
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            
            return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + units[i];
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function showProgress() {
            const progressContainer = document.getElementById('progressContainer');
            if (progressContainer) {
                progressContainer.style.display = 'block';
            }
        }

        function hideProgress() {
            const progressContainer = document.getElementById('progressContainer');
            if (progressContainer) {
                progressContainer.style.display = 'none';
                updateProgress(0, '업로드 준비 중...');
            }
        }

        function updateProgress(percent, text) {
            const progressBar = document.getElementById('progressBar');
            const progressText = document.getElementById('progressText');
            
            if (progressBar) {
                progressBar.style.width = percent + '%';
                progressBar.textContent = Math.round(percent) + '%';
            }
            
            if (progressText) {
                progressText.textContent = text || '업로드 중...';
            }
        }

        function showMessage(message, type) {
            const statusDiv = document.getElementById('uploadStatus');
            if (statusDiv) {
                statusDiv.textContent = message;
                statusDiv.className = 'upload-status ' + type;
                statusDiv.style.display = 'block';
                
                if (type === 'success') {
                    setTimeout(function() {
                        hideMessage();
                    }, 5000);
                }
            }
            
            console.log('메시지 [' + type + ']: ' + message);
        }

        function hideMessage() {
            const statusDiv = document.getElementById('uploadStatus');
            if (statusDiv) {
                statusDiv.style.display = 'none';
                statusDiv.className = 'upload-status';
            }
        }

        function handleFormSubmit() {
            if (selectedFiles.length === 0) {
                showMessage('업로드할 파일을 선택해주세요.', 'error');
                return;
            }

            const formData = new FormData();
            
            const pathInput = document.querySelector('input[name="path"]');
            if (pathInput) {
                formData.append('path', pathInput.value);
            }
            
            selectedFiles.forEach(function(file) {
                formData.append('uploadFiles', file);
            });

            console.log('FormData 생성 완료, 파일 수:', selectedFiles.length);

            showProgress();
            updateProgress(0, '업로드 시작 중...');
            
            const uploadBtn = document.getElementById('uploadBtn');
            if (uploadBtn) {
                uploadBtn.disabled = true;
            }
            
            hideMessage();

            const xhr = new XMLHttpRequest();
            
            xhr.upload.addEventListener('progress', function(e) {
                if (e.lengthComputable) {
                    const percentComplete = (e.loaded / e.total) * 100;
                    updateProgress(percentComplete, '업로드 중... (' + selectedFiles.length + '개 파일)');
                }
            });

            xhr.addEventListener('load', function() {
                console.log('업로드 응답 상태:', xhr.status);
                
                if (xhr.status === 200) {
                    updateProgress(100, '업로드 완료!');
                    showMessage('파일 업로드가 완료되었습니다! 잠시 후 파일 목록으로 이동합니다.', 'success');
                    
                    setTimeout(function() {
                        const pathInput = document.querySelector('input[name="path"]');
                        const pathParam = pathInput && pathInput.value ? '?path=' + pathInput.value : '';
                        window.location.href = 'downlist.jsp' + pathParam;
                    }, 3000);
                    
                } else {
                    hideProgress();
                    showMessage('업로드 중 서버 오류가 발생했습니다. (상태 코드: ' + xhr.status + ')', 'error');
                    if (uploadBtn) {
                        uploadBtn.disabled = false;
                    }
                }
            });

            xhr.addEventListener('error', function() {
                console.error('업로드 네트워크 오류');
                hideProgress();
                showMessage('업로드 중 네트워크 오류가 발생했습니다.', 'error');
                if (uploadBtn) {
                    uploadBtn.disabled = false;
                }
            });

            xhr.addEventListener('timeout', function() {
                console.error('업로드 타임아웃');
                hideProgress();
                showMessage('업로드 시간이 초과되었습니다. 파일 크기를 확인해주세요.', 'error');
                if (uploadBtn) {
                    uploadBtn.disabled = false;
                }
            });

            xhr.open('POST', 'uploadProcess.jsp', true);
            xhr.timeout = 300000;
            xhr.send(formData);
            
            console.log('AJAX 업로드 시작');
        }
    </script>
</body>
</html>