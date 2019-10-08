pragma solidity ^0.4.25;

/*

亲爱的各位家人们，十分高兴到现在大家还能聚集在一起。这些天的日夜赶工再次累死一班程序猿，终于搭通区块的桥梁。是否能够实现跨界打劫，能否实现财富自由就看家人们你们的推广热度啦，在这里我诚恳地对家人们说：平台需要你们。

以下是我们的技术团队日以继夜努力的成果：

一、合约说明

我们当前部署了以下合约：

coToken代币，地址0x03cb0021808442ad5efb61197966aef72a1def96

层级关系，地址0x62a364f7cba3be8fc9dcfdde12cabec8244af381

FUS股份，地址0x573aaaa81154cd24e96f0cb97fd86110b8f6767f

众筹活动插件，地址0x9af285f84645892dd57ae135af6e97f952a5922c

特级会员设置插件，地址0xfefe4e22fb4ee9abe6f7dfadf2e0a08b04869468

项目注册插件，地址0xc931147a08597294a9848f80fa7b929fa68c160c


1. coToken代币是在所有项目使用的代币，永远与以太币等价，此合约负责coToken与以太币的互转。向此合约转入以太币，此合约则生成等量的coToken代币。从此合约提出以太币，则此合约销毁等量的coToken代币。

使用代币有多种好处，首先是避免死币。以下两个游戏，囤积了大量死币：

a. https://p3d-bot.github.io/buy.html，合约地址0xb3775fb83f7d12a36e0475abdd1fca35c091efbe，存有3万5千多以太币。此游戏的规则是，提币的人要给不提币的人收益，导致大家都不敢提币，把币砸在里面形成死币。

b. https://exitscam.me/play，合约地址0xa62142888aba8370742be823c1782d17a0389da1，也就是大家熟悉的Fomo3D，合约里有1400以太币，但奖池中只有不足1币。大量在游戏中获得小量奖励的账号，每个账号的奖励可能比提奖需要的矿工费还要少。于是奖励被放弃了，积累成死币。同样问题还出现在LW中。

因此，使用coToken作代币进行游戏，可以避免死币形成，使家人们的财产得到有效的使用。

由于所有与以太坊有关的应用和程序，都关心一个账号的余额，因此使用代币，可避免某些不希望受到的关注。

由于以太坊合约的固有特性，发送以太币到某个合约，有可能触发其默认回调函数，从而引起安全问题。而使用代币，并不直接调用该合约，从而避免了某些安全问题，也避免了合约地址冒充普通账号的钓鱼和攻击。

这些特性及代币的更多优点，此处不便一一说明，但大家以后会看到它的巧妙作用。

2. 层级关系合约，保存了所有已注册会员的层级关系，以及下级给上级的提成。

3. FUS股份，保存了会员占有FUS的数量，各个项目的分红，以及会员通过股权分配收益的相关信息。

FUS要有价值，必须是自身能产生收益！若自身不能产生收益，单靠凭空炒作，其价值即使短期上升，最终也会回到起点。空气币项目比比皆是，追求刺激的家人可以自行选择参与。但这不是我们FUS的使命。

我们利用我们的推广力量，扩大我们项目的影响，用实在的应用，吸引大量非会员加入，使我们的项目价值不断提升，由FUS产生的分红和权利就会得到实质性的变现，FUS在交易市场上的溢价交易就有坚实的客观基础。

我们未来的应用中，有些是需要参与才会获得分红，有些是不需要参与，只需要持有FUS就能获得分红。

除此以外，未来FUS也会成为有效资产的一种形式，成为个人信用的有效载体。

FUS暂时不可向系统购买，但使用某些应用会获得FUS奖励，具体需查看该应用的说明。待交易所上线后，可在交易所中购买别人的FUS。这样的目的，是控制FUS的数量，防止FUS贬值。系统暂已发行2亿FUS，除了之前众筹分发出的部分，其余全部未有所属，甚至也不属于平台方。而且未有所属的FUS不参与计算分红。

4. 以太坊合约一旦部署，就不可修改。因此，我们的整个系统，会由大量合约组成，以上三个合约是核心合约，留出功能扩展接口以及权限控制接口。其余合约，作为插件形式，调用核心合约的接口，从而形成一个微核心，但高可扩展的合约群。如果大家听到某些系统功能如何强大，但除了产币卖币之外什么功能也没见到的，笑笑就可以了，别当真。

众筹活动、特级会员设置、项目注册、包括即将上线的LW2，都是插件型合约，必要时可以切断其与核心合约的联系，或进行升级迁移，有效保障了家人们的财产安全。

5. 由于以太坊系统中没有版权保护，因此暂时不会将合约的源代码公开，以免被用心不良者抄袭和行骗。


二、会员收益说明


1. 层级提成 —— 平台现在采用两级的层级提成，这是必须要走的路，（会员对外推广平台项目获得会员直属下级对会员的提成，及会员直属下下级对会员的提成。无特殊说明则分别为6%和3%。）

2. 合作者分成 —— 若某项目有合作者（可以是公司或某些会员），则其会获得已约定的分成。

3. 股权分成 —— 作为对有权获得此项目分红，并持有FUS的股东的股权收益，定期分红。

4. 新项目参与奖励众筹 —— 当平台推出新项目，凡参与投入者可增加其众筹FUS的数量，数量越多，分红越多。

PS:无论是否是注册会员，只要参与使用和推广我们平台推出的项目应用，都会成为我们的会员并获得相应的股权以及分红.


这里着重说明一下层级提成。

层级提成：多劳多得，下级越多将可能获得越多提成；但饮水思源，自己有钱赚，就不能亏待自己的上级。

会员加入层级后，若获得提成，必须优先保证上级的利益，从而杜绝用自己的大号发展自己的小号，饿死上级的问题。因为自己的大号需要留住小号的提成，也必须先保证大号的上级的提成。

一般来说，每个账号只需在有层级提成的前提下，保证自己上级获得总计0.8ETH，就可以获得下级和下下级贡献的提成，不需再向上级上传收益。但自己本身发生的投入项目行为，还是会为上级贡献提成的。

若一个账号只做推广，不进行付费活动，则在其下线对其提供的层级提成中，总计前0.8ETH归其上级，剩余的就是其自己的收益。

若一个账号从来没有获得下级提成，也不进行付费活动，则无需向上级提供收益，依然可以从FUS中获得分红。


另外需要提到一点的是我们新上的功能：

我们要跨界打劫，怎么能赤手空拳呢？！我们团队为家人们准备了威力强大的武器：面对面收发！这个应用，为大家发展下级扫清了障碍，能加快注入新鲜血液，壮大我们的力量。相信很多家人应该已经更新下载了。那么在这里我做一个介绍：当会员发送给非会员时，则该非会员的接收列表中会出现会员的推荐链接，只要非会员点击链接并注册就能发展成为新会员，新会员归属于该会员的下级。这样既能够让会员们更便捷的发展下级，同时为新会员提供更普惠更便利的获得数字货币的渠道。这个应用的落地完全是合法合情的，大家大可放心推广，发挥我们强大的推广生态。这个应用的扩散以及LW2.0的上线会让我们平台的数字货币迈向世界第三大数字货币奠定的十分坚实的基础。必须强调一点，我们现在所做的这些推广都是合情合法合理，没有触犯国家任何法律条文，各位家人再次把你们当时推广平台的热情高涨带回来，我们可以跨界，我们可以腾飞。

这一路风雨走来，家人们依然能留守自己的岗位，是对我们努力最大的肯定。是时候展示我们家人们强大的推广能力了。再次呼唤家人们，跨界打劫的时刻已经来临。

*/

contract MSD9 {
    
    function action() public {
        
    }
}