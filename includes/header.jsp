<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - 게시판 시스템</title>
    <!-- 기본 스타일시트 임포트 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main_style.css">
    <!-- 아카이브 스타일시트 -->
	<%--     <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/archive_style.css"> --%>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
</head>
<body>
    <header class="main-header">
        <div class="container">
            <div class="logo">
                <a href="${pageContext.request.contextPath}/dashboard" class="logo-icon" style="display: flex; align-items: center;">
			        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="28" height="28">
			            <path d="M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5c0-1.1.9-2 2-2zm0 2v14h14V5H5zm2 2h10v2H7V7zm0 4h10v2H7v-2zm0 4h7v2H7v-2z" fill="#333333" opacity="0.9"/>
			        </svg>
                </a>	
                <span class="logo-text">업무개선</span>
            </div>
            
            <nav class="main-nav">
                <ul>
                    <!-- 대시보드 -->
                    <li>
                        <a href="${pageContext.request.contextPath}/dashboard" class="${pageTitle eq '대시보드' ? 'active' : ''}">
                            <i class="fas fa-tachometer-alt mr-1"></i>대시보드
                        </a>
                    </li>
                    
                    
                    <!-- 고객관리 드롭다운 -->
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle ${pageTitle eq '고객사 정보' || pageTitle eq '정기점검 이력' ? 'active' : ''}">
                            <i class="fas fa-building mr-1"></i>고객관리
                            <!-- <i class="fas fa-caret-down ml-1"></i> -->
                        </a>
                        <ul class="dropdown-menu">
                            <li>
                                <a href="${pageContext.request.contextPath}/customers?view=list">
                                    <i class="fas fa-address-card mr-2"></i>고객사 정보
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/maintenance">
                                    <i class="fas fa-clipboard-check mr-2"></i>정기점검 이력
                                </a>
                            </li>
                        </ul>
                    </li>
                                        <!-- 자료관리 드롭다운 -->
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle ${pageTitle eq '업무자료' || pageTitle eq '회의자료' || pageTitle eq '기타자료' ? 'active' : ''}">
                            <i class="fas fa-folder mr-1"></i>자료관리
                            <!-- <i class="fas fa-caret-down ml-1"></i> -->
                        </a>	
                        <ul class="dropdown-menu">
                            <li>
							    <a href="${pageContext.request.contextPath}/meeting?view=list">
							        <i class="fas fa-clipboard-list mr-2"></i>회의록	
							    </a>
							</li>
                            <li>
                                <a href="${pageContext.request.contextPath}/downlist.jsp">
                                    <i class="fas fa-file-alt mr-2"></i>자료실
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/troubleshooting?view=list">
                                    <i class="fas fa-file-alt mr-2"></i>트러블슈팅
                                </a>
                            </li>
                        </ul>
                    </li>
                    
                    <!-- 마이페이지 -->
                    <li>
                        <a href="http://192.168.40.70:8080" class="${pageTitle eq 'OLLAMA' ? 'active' : ''}">
                            <i class="fas fa-user mr-1"></i>OLLAMA
                        </a>
                    </li> 
                    
                    <!-- 로그아웃 -->
                    <li>
                        <a href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt mr-1"></i>로그아웃
                        </a>
                    </li>
                </ul>	
            </nav>
        </div>
    </header>
    
    <!-- 드롭다운 메뉴를 위한 스타일 및 스크립트 -->
    <style>
        /* 드롭다운 메뉴 스타일 */
        .main-nav ul li.dropdown {
            position: relative;
        }
        
        .main-nav ul li.dropdown .dropdown-menu {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            background-color: var(--card-bg);
            box-shadow: var(--shadow-md);
            border-radius: 6px;
            min-width: 200px;
            z-index: 1000;
            padding: 8px 0;
            margin-top: 5px;
        }
        
        
        .main-nav ul li.dropdown:hover .dropdown-menu {
            display: block;
        }
        
        .main-nav ul li.dropdown .dropdown-menu li {
            display: block;
            margin: 0;
        }
        
        .main-nav ul li.dropdown .dropdown-menu li a {
            padding: 8px 16px;
            display: block;
            color: var(--neutral-600);
            font-size: 14px;
        }
        
        .main-nav ul li.dropdown .dropdown-menu li a:hover {
            background-color: var(--primary-light);
            color: var(--primary);
        }
        
        /* 반응형 대응 */
        @media (max-width: 768px) {
            .main-nav ul {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .main-nav ul li {
                margin-bottom: 5px;
                width: 100%;
            }
            
            .main-nav ul li.dropdown .dropdown-menu {
                position: static;
                box-shadow: none;
                padding-left: 20px;
                width: 100%;
                display: none;
            }
            
            .main-nav ul li.dropdown.open .dropdown-menu {
                display: block;
            }
        }
        
        /* 도우미 클래스 */
        .mr-1 {
            margin-right: 5px;
        }
        
        .mr-2 {
            margin-right: 10px;
        }
        
        .ml-1 {
            margin-left: 5px;
        }
    </style>
    
    <script>
        $(document).ready(function() {
            // 모바일 환경에서 드롭다운 토글
            $('.main-nav ul li.dropdown > a').on('click', function(e) {
                if ($(window).width() <= 768) {
                    e.preventDefault();
                    $(this).parent().toggleClass('open');
                }
            });
            
            // 현재 메뉴 활성화
            const path = window.location.pathname;
            const query = window.location.search;
            
            // 자료관리 메뉴 활성화
            if (path.includes('/archive')) {
                $('.main-nav ul li.dropdown').eq(0).addClass('active');
                
                if (query.includes('category=business')) {
                    $('.main-nav ul li.dropdown').eq(0).find('.dropdown-toggle').text('업무자료');
                } else if (query.includes('category=meeting')) {
                    $('.main-nav ul li.dropdown').eq(0).find('.dropdown-toggle').text('회의자료');
                } else if (query.includes('category=etc')) {
                    $('.main-nav ul li.dropdown').eq(0).find('.dropdown-toggle').text('기타자료');
                }
            }
            
            // 고객관리 메뉴 활성화
            if (path.includes('/customers') || path.includes('/maintenance')) {
                $('.main-nav ul li.dropdown').eq(1).addClass('active');
                
                if (path.includes('/customers')) {
                    $('.main-nav ul li.dropdown').eq(1).find('.dropdown-toggle').text('고객사 정보');
                } else if (path.includes('/maintenance')) {
                    $('.main-nav ul li.dropdown').eq(1).find('.dropdown-toggle').text('정기점검 이력');
                }
            }
        });
    </script>