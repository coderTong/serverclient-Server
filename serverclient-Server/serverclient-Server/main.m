//
//  main.m
//  server-client
//
//  Created by codew on 2017/6/16.
//  Copyright © 2017年 codew. All rights reserved.
//

#include <sys/socket.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

#define ERR_EXIT(m)\
do\
{\
perror(m);\
exit(EXIT_FAILURE);\
}while(0)\

int main(void) {
    
    // 1. 创建套接字----man socket
    int listenfd;
    /**
     AF_INET ---IPV4
     AF_INET6 ---IPV6
     
     PF_INET和AF_INET值是一样的, P-protocol f-family INE网际协议
     
     PF_INET, SOCK_STREAM 这两个决定了是TCP协议---然后第三个参数习惯上是0, 亦可以指定它索要的协议
     第三个参数0表示自动,网际加流式一定是TCP所以可以不填
     */
    
    //listenfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    listenfd = socket(PF_INET, SOCK_STREAM, 0);
    
    if (listenfd < 0) {
        //        NSLog(@"失败");
        ERR_EXIT("socket");
    }
    
    // 2. 绑定一个地址----绑定一个电话号码-----地址初始化
    struct sockaddr_in servaddr;
    memset(&servaddr, 0, sizeof(servaddr));// 初始化地址
    
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(5189);// 将5188转换成网络字节序, s表示两个字节
    //    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);// INADDR_ANY 表示本机的任意地址 ----推荐使用这个...
    //    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    servaddr.sin_addr.s_addr = inet_addr("162.243.64.148");
    //    inet_aton("162.243.64.148", &servaddr.sin_addr);
    
    // 3.bind----地址绑定
    int bindResult = bind(listenfd, &servaddr, sizeof(servaddr));
    
    if (bindResult < 0) {
        // 绑定失败
        ERR_EXIT("bind--error");
    }
    
    // 4. listen--- 监听
    /***
     SOMAXCONN--调用了这个函数后我们的socket就成了被动套接字
     被动套接字:: 是用来接受连接的    accept
     主动套接字: 是用来发起连接    connect
     
     一般来说,listen函数应该在调用socket和bind函数之后,调用函数accept之前调用.
     
     对于给定的监听套接口, 内核要维护两个队列,:
     1. 已由客户发出并到达服务器, 服务器正在等待完成相应的tcp三次握手过程
     2. 已完成连接的队列
     */
    int listenResult = listen(listenfd, SOMAXCONN);//
    if (listenResult < 0) {
        // 监听失败
        ERR_EXIT("listen --error");
    }
    
    // 5. accept
    struct sockaddr_in peeraddr; // 对方的地址
    socklen_t peerLen = sizeof(peeraddr);// 对方的地址长度--peerLen一定要有初始值
    int acceptResult = accept(listenfd, (struct sockaddr *)&peeraddr, &peerLen);
    if (acceptResult < 0) {// 接受连接,从已完成连接的对头得到一个连接
        ERR_EXIT("accept --error");
    }
    // acceptResult 是新得到的一个套接字---已连接套接字-----主动套接字
    char recvbuf[1024];
    char stringS[1024] = "来至162.243.64.148的回复....";
    while (1) {
        memset(recvbuf, 0, sizeof(recvbuf));
        int ret = read(acceptResult, recvbuf, sizeof(recvbuf));
        fputs(recvbuf, stdout);
        //        write(acceptResult, recvbuf, ret);
        write(acceptResult, stringS, sizeof(stringS));
    }
    
    close(listenfd);
    
    return 0;
}
