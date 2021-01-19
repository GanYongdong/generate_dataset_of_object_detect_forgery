function write_xml(writefilename, size_, data, labelStrSet)
% дxml�ļ������д�Ĺ̶����ڱ�׼yolo��ǩxml�ļ���
% writefilename�Ǳ�����ļ�·�����ƣ�
% size_��[width,height,depth]��������
% data��n�е����ݣ�ÿ�д���һ��Ŀ����󣬵�һ��������ţ����ִ�����4 5 10 11�зֱ���xmin ymin xmax ymax
% author: ganyongdong <1141951289@qq.com> 2020.8.22

% create document
docNode = com.mathworks.xml.XMLUtils.createDocument('annotation');

% document element
docRootNode = docNode.getDocumentElement();

% folder
nameNode = docNode.createElement('folder');
nameNode.appendChild(docNode.createTextNode(sprintf('image')));
docRootNode.appendChild(nameNode);

% filename
nameNode = docNode.createElement('filename');
nameNode.appendChild(docNode.createTextNode(sprintf('file path')));
docRootNode.appendChild(nameNode);

% source
nameNode = docNode.createElement('source');
nameNode_c = docNode.createElement('database');
nameNode_c.appendChild(docNode.createTextNode(sprintf('Unknown')));
nameNode.appendChild(nameNode_c);
docRootNode.appendChild(nameNode);

% size
width = size_(1,1);
height = size_(1,2);
depth = size_(1,3);
nameNode = docNode.createElement('size');
nameNode_c = docNode.createElement('width');
nameNode_c.appendChild(docNode.createTextNode(sprintf('%d',width)));
nameNode.appendChild(nameNode_c);
nameNode_c = docNode.createElement('height');
nameNode_c.appendChild(docNode.createTextNode(sprintf('%d',height)));
nameNode.appendChild(nameNode_c);
nameNode_c = docNode.createElement('depth');
nameNode_c.appendChild(docNode.createTextNode(sprintf('%d',depth)));
nameNode.appendChild(nameNode_c);
docRootNode.appendChild(nameNode);

% segmented
nameNode = docNode.createElement('segmented');
nameNode.appendChild(docNode.createTextNode(sprintf('0')));
docRootNode.appendChild(nameNode);

for i = 1 : size(data, 1)
    % while
    % object
    xmin = data(i,4);
    ymin = data(i,5);
    xmax = data(i,10);
    ymax = data(i,11);
    nameNode = docNode.createElement('object');
    nameNode_c = docNode.createElement('name');
    labelStr = labelStrSet(data(i,1),1); %��idת���ɶ�Ӧ���ַ���
    nameNode_c.appendChild(docNode.createTextNode(labelStr));
    nameNode.appendChild(nameNode_c);
    nameNode_c = docNode.createElement('pos');
    nameNode_c.appendChild(docNode.createTextNode(sprintf('Unspecified')));
    nameNode.appendChild(nameNode_c);
    nameNode_c = docNode.createElement('truncated');
    nameNode_c.appendChild(docNode.createTextNode(sprintf('1')));
    nameNode.appendChild(nameNode_c);
    nameNode_c = docNode.createElement('difficult');
    nameNode_c.appendChild(docNode.createTextNode(sprintf('0')));
    nameNode.appendChild(nameNode_c);
    nameNode_c = docNode.createElement('bndbox');
    nameNode_c_c = docNode.createElement('xmin');
    nameNode_c_c.appendChild(docNode.createTextNode(sprintf('%d',xmin)));
    nameNode_c.appendChild(nameNode_c_c);
    nameNode_c_c = docNode.createElement('ymin');
    nameNode_c_c.appendChild(docNode.createTextNode(sprintf('%d',ymin)));
    nameNode_c.appendChild(nameNode_c_c);
    nameNode_c_c = docNode.createElement('xmax');
    nameNode_c_c.appendChild(docNode.createTextNode(sprintf('%d',xmax)));
    nameNode_c.appendChild(nameNode_c_c);
    nameNode_c_c = docNode.createElement('ymax');
    nameNode_c_c.appendChild(docNode.createTextNode(sprintf('%d',ymax)));
    nameNode_c.appendChild(nameNode_c_c);
    nameNode.appendChild(nameNode_c);
    docRootNode.appendChild(nameNode);
end

% xmlwrite
xmlwrite(writefilename, docNode);

end
