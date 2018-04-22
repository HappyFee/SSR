#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH


#�������
#��Ȩ�ļ��Զ�����url
APX=http://rs.91yun.pw/apx1.php
#��װ�����ص�ַ
INSTALLPACK=https://github.com/91yun/serverspeeder/blob/test/91yunserverspeeder.tar.gz?raw=true
#�жϰ汾֧������ĵ�ַ
CHECKSYSTEM=https://raw.githubusercontent.com/91yun/serverspeeder/test/serverspeederbin.txt
#bin���ص�ַ
BINURL=http://rs.91yun.pw/



#ȡ����ϵͳ������
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        release='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        release='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        release='Ubuntu'
        PM='apt'		
	else
        release='unknow'
    fi
    
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        bit='x64'
    else
        bit='x32'
    fi
}

Get_Dist_Name
Get_OS_Bit
kernel=`uname -r`
kernel_result=""

echo -e "\r\n"
echo "===============System Info======================="
echo "$release "
echo "$kernel "
echo "$bit "
echo "================================================="
echo -e "\r\n"

#����֧�ֵ��ں˿�
wget $CHECKSYSTEM --no-check-certificate -O serverspeederbin.txt || { echo "Error downloading file, please try again later.";exit 1; }

#�ж��Ƿ�����ȫƥ����ں�
grep -q "$release/[^/]*/$kernel/$bit" serverspeederbin.txt
if [ $? -eq 0 ]; then
	#�����ȫƥ�䣬��ȡ���ں˰汾
	kernel_result=$kernel
else
	#���û����ȫƥ����ںˣ���ʼģ��ƥ��
	echo ">>>This kernel is not supported. Trying fuzzy matching..."
	echo -e "\r\n"
	#��Ϊcentos��ubuntu�İ汾�Ų�̫һ��������centosƥ��2.6.32-504.el6.x86_64��504 ��
	if [ "$release" == "CentOS" ]; then
		kernel1=`echo $kernel | awk -F '-' '{ print $1 }'`
		kernel2=`echo $kernel | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }'`
	elif [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		kernel1=`echo $kernel | awk -F '-' '{ print $1 }'`
		kernel2=`echo $kernel | awk -F '-' '{ print $2 }'`
	else
		echo "This script only supports CentOS, Ubuntu and Debian."
		exit 1
	fi
	
	grep -q "$release/[^/]*/$kernel1\(-\)\{0,1\}$kernel2[^/]*/$bit" serverspeederbin.txt
	if [ $? -eq 1 ]; then
			echo -e "\r\n"
			echo -e "Serverspeeder is not supported on this kernel! View all supported systems and kernels here:\033[41;37m https://www.91yun.org/serverspeeder91yun \033[0m"
			exit 1
	else
		#���ģ��ƥ�䵽�ˣ��͸����ѡ
		echo "There is no exact match for this kernel, please choose the closest one below:"
		echo -e "The current kernel is \033[41;37m $kernel \033[0m"
		echo -e "\r\n"
		cat serverspeederbin.txt | grep  "$release/[^/]*/$kernel1\(-\)\{0,1\}$kernel2[^/]*/$bit"  | awk -F '/' '{ print NR"��"$3 }'
		echo -e "\r\n"
		echo "Please enter the number of your option��"	
		read cver2
		if [ "$cver2" == "" ]; then
			echo "You did not choose any kernel options. Installation terminated."
			exit 1
		fi
		echo -e "\r\n"
		cver2str="cat serverspeederbin.txt | grep  \"$release/[^/]*/$kernel1\(-\)\{0,1\}$kernel2[^/]*/$bit\"  | awk -F '/' '{ print NR\"��\"\$3 }' | awk -F '��' '/"$cver2��"/{ print \$2 }' | awk 'NR==1{print \$1}'"
		kernel_result=$(eval $cver2str)			
	fi
fi

if [ "$kernel_result" == "" ]; then
	echo "Unable to get kernel information. Installtion terminated."
	exit 1
fi

echo "Installing ServerSpeeder, please wait for a moment..."


#��ʼƥ�����ٵİ汾
serverspeederver=3.10.61.0

grep -q "$release/[^/]*/$kernel_result/$bit/$serverspeederver" serverspeederbin.txt
if [ $? == 1 ]; then
	#���û��ƥ�䵽����汾�����٣���ȡ��һ��
	serverspeederverstr="grep \"$release/[^/]*/$kernel_result/$bit/\" serverspeederbin.txt | awk -F '/' 'NR==1{print \$5}'"
	serverspeederver=$(eval $serverspeederverstr)
fi



BINFILESTR="cat serverspeederbin.txt | grep '$release/[^/]*/$kernel_result/$bit/$serverspeederver/0' | awk -F '/' '{ print \$1\"/\"\$2\"/\"\$3\"/\"\$4\"/\"\$5\"/\"\$7 }'"
BINFILE=$(eval $BINFILESTR)
if [ "$BINFILE" == "" ]; then
	echo "Unable to get BINFILE. Installation terminated."
	exit 1
fi
BIN=${BINURL}${BINFILE}
rm -rf serverspeederbin.txt





if [ "$1" == "" ]; then
	MACSTR="LANG=C ifconfig eth0 | awk '/HWaddr/{ print \$5 }' "
	MAC=$(eval $MACSTR)
	if [ "$MAC" == "" ]; then
		MACSTR="LANG=C ifconfig eth0 | awk '/ether/{ print \$2 }' "
		MAC=$(eval $MACSTR)
	fi	
	if [ "$MAC" == "" ]; then
		echo "The name of network interface is not eth0, please retry after changing the name."
		exit 1
	fi
else
	MAC=$1
fi	

#����Զ�ȡ�������˳�
if [ "$MAC" = "" ]; then
	echo "Unable to get MAC address. Installation terminated."
	exit 1
fi

	
#���ذ�װ��
wget -N --no-check-certificate -O 91yunserverspeeder.tar.gz  $INSTALLPACK 
tar xfvz 91yunserverspeeder.tar.gz || { echo "Unable to download Installation package. Installation terminated.";exit 1; }

#������Ȩ�ļ�
wget -N --no-check-certificate -O apx.lic "$APX?mac=$MAC" || { echo "Unable to download lic file, please check: $APX?mac=$MAC";exit 1;}
mv apx.lic 91yunserverspeeder/apxfiles/etc/


#ȡ�����к�

wget -N --no-check-certificate -O serverspeedersn.txt "$APX?mac=$MAC&sno"
SNO=$(cat serverspeedersn.txt)
rm -rf serverspeedersn.txt
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" 91yunserverspeeder/apxfiles/etc/config
sed -i "s/apx-20341231/apx/g" 91yunserverspeeder/apxfiles/etc/config
rv=$release"_"$kernel_result
sed -i "s/acce-3.10.61.0-\[Debian_7_3.2.0-4-amd64\]/acce-$serverspeederver-[$rv]/g" 91yunserverspeeder/apxfiles/etc/config

#����bin�ļ�;
wget -N --no-check-certificate -O "acce-"$serverspeederver"-["$release"_"$kernel_result"]" $BIN 
mv "acce-"$serverspeederver"-["$release"_"$kernel_result"]" 91yunserverspeeder/apxfiles/bin/

#�л�Ŀ¼ִ��װ�ļ�
cd 91yunserverspeeder
bash install.sh

#��ֹ�޸���Ȩ�ļ�
#chattr +i /serverspeeder/etc/apx*
bash /serverspeeder/bin/serverSpeeder.sh status